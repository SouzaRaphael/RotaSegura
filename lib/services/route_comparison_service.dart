import '../models/place.dart';
import '../models/rain_forecast.dart';
import '../models/route_analysis.dart';
import 'analysis/geo_utils.dart';
import 'analysis/route_exposure_analyzer.dart';
import 'api/api_client.dart';
import 'api/forecast_service.dart';
import 'api/rain_station_service.dart';
import 'api/routing_service.dart';

class RouteComparisonService {
  RouteComparisonService({
    RoutingService? routing,
    RainStationService? stations,
    ForecastService? forecast,
    DateTime Function()? clock,
  }) : _routing = routing ?? RoutingService(),
       _stations = stations ?? RainStationService(),
       _forecast = forecast ?? ForecastService(),
       _clock = clock ?? DateTime.now;

  final RoutingService _routing;
  final RainStationService _stations;
  final ForecastService _forecast;
  final DateTime Function() _clock;

  static const samplesPerRoute = 4;

  Future<RouteComparison> compare(Place origin, Place destination, {required int radiusKm}) async {
    if (origin.isSameLocation(destination)) {
      throw const ApiException('A origem e o destino precisam ser locais diferentes.');
    }
    final routesFuture = _routing.fetchRoutes(origin, destination);
    final stationsFuture = _optional(_stations.fetchStations());
    final routes = await routesFuture;

    final samples = routes.map((route) => GeoUtils.samplePoints(route.points, samplesPerRoute)).toList();
    final forecasts = await _optional(_forecast.fetchForecasts(samples.expand((points) => points).toList(), hours: 6));
    final stations = await stationsFuture;

    List<List<RainForecast>>? forecastsByRoute;
    if (forecasts != null) {
      forecastsByRoute = [];
      var offset = 0;
      for (final points in samples) {
        forecastsByRoute.add(forecasts.sublist(offset, offset + points.length));
        offset += points.length;
      }
    }

    return RouteExposureAnalyzer(radiusMeters: radiusKm * 1000.0).compare(
      routes: routes,
      stations: stations,
      forecastsByRoute: forecastsByRoute,
      now: _clock(),
    );
  }

  static Future<T?> _optional<T>(Future<T> future) async {
    try {
      return await future;
    } on ApiException {
      return null;
    }
  }
}
