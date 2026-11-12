import 'dart:math' as math;

import '../../models/driving_route.dart';
import '../../models/rain_forecast.dart';
import '../../models/rain_station.dart';
import '../../models/route_analysis.dart';
import '../../utils/formatters.dart';
import 'geo_utils.dart';

class RouteExposureAnalyzer {
  const RouteExposureAnalyzer({this.radiusMeters = 2000, this.forecastHours = 3, this.tolerance = 0.5});

  final double radiusMeters;
  final int forecastHours;

  final double tolerance;

  RouteComparison compare({
    required List<DrivingRoute> routes,
    required List<RainStation>? stations,
    required List<List<RainForecast>>? forecastsByRoute,
    required DateTime now,
  }) {
    if (routes.isEmpty) throw ArgumentError('Nenhuma rota para comparar.');

    final fastestIndex = _indexOfMin(routes.map((route) => route.durationSeconds).toList());
    final drafts = <_Draft>[];
    for (var i = 0; i < routes.length; i++) {
      final nearby = stations == null ? <NearbyStation>[] : _nearbyStations(routes[i], stations, now);
      final forecasts = forecastsByRoute?[i];
      drafts.add(
        _Draft(
          route: routes[i],
          nearby: nearby,
          observed: stations == null ? null : nearby.fold<double>(0, (m, s) => math.max(m, s.station.rainfall)),
          forecast: forecasts?.fold<double>(0, (m, f) => math.max(m, f.totalFor(forecastHours))),
          probability: forecasts?.fold<int>(0, (m, f) => math.max(m, f.maxProbabilityFor(forecastHours))),
        ),
      );
    }

    final lowest = drafts.map((draft) => draft.exposure).reduce(math.min);
    var recommendedIndex = -1;
    for (var i = 0; i < drafts.length; i++) {
      if (drafts[i].exposure - lowest > tolerance) continue;
      if (recommendedIndex == -1 || routes[i].durationSeconds < routes[recommendedIndex].durationSeconds) {
        recommendedIndex = i;
      }
    }

    final analyses = [
      for (var i = 0; i < drafts.length; i++)
        RouteAnalysis(
          route: drafts[i].route,
          nearbyStations: drafts[i].nearby,
          observedRain: drafts[i].observed,
          forecastRain: drafts[i].forecast,
          forecastProbability: drafts[i].probability,
          isFastest: i == fastestIndex,
          isRecommended: i == recommendedIndex,
          hasHigherExposure: drafts[i].exposure - drafts[recommendedIndex].exposure > tolerance,
        ),
    ];

    return RouteComparison(
      routes: analyses,
      recommendedIndex: recommendedIndex,
      reason: _reason(analyses, recommendedIndex, fastestIndex, noData: stations == null && forecastsByRoute == null),
      stationsAvailable: stations != null,
      forecastAvailable: forecastsByRoute != null,
      forecastHours: forecastHours,
      radiusMeters: radiusMeters,
      checkedAt: now,
    );
  }

  List<NearbyStation> _nearbyStations(DrivingRoute route, List<RainStation> stations, DateTime now) {
    final result = <NearbyStation>[];
    for (final station in stations) {
      if (station.isStale(now)) continue;
      final distance = GeoUtils.distanceToPolylineMeters(station.point, route.points);
      if (distance <= radiusMeters) result.add(NearbyStation(station: station, distanceMeters: distance));
    }
    result.sort((a, b) {
      final byRain = b.station.rainfall.compareTo(a.station.rainfall);
      return byRain != 0 ? byRain : a.distanceMeters.compareTo(b.distanceMeters);
    });
    return result;
  }

  String _reason(List<RouteAnalysis> routes, int recommended, int fastest, {required bool noData}) {
    if (noData) {
      return 'Não foi possível consultar a chuva agora. As rotas estão ordenadas apenas pelo tempo de viagem.';
    }
    if (routes.length == 1) {
      return 'Encontramos uma rota para este trajeto. Veja abaixo a chuva observada e prevista no caminho.';
    }
    if (routes.every((item) => item.exposure < 0.2)) {
      return 'Não há chuva registrada nem prevista perto das rotas. Recomendamos a mais rápida.';
    }
    if (recommended == fastest) {
      return 'A rota mais rápida também é a de menor exposição à chuva no momento.';
    }
    final extra = routes[recommended].route.minutes - routes[fastest].route.minutes;
    final difference = routes[fastest].exposure - routes[recommended].exposure;
    return 'A rota recomendada leva ${Formatters.minutesDifference(extra)} e tem '
        '${Formatters.millimeters(difference)} a menos de chuva observada e prevista no caminho.';
  }

  static int _indexOfMin(List<double> values) {
    var index = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] < values[index]) index = i;
    }
    return index;
  }
}

class _Draft {
  _Draft({required this.route, required this.nearby, this.observed, this.forecast, this.probability});

  final DrivingRoute route;
  final List<NearbyStation> nearby;
  final double? observed;
  final double? forecast;
  final int? probability;

  double get exposure => (observed ?? 0) + (forecast ?? 0);
}
