import 'driving_route.dart';
import 'rain_station.dart';

class NearbyStation {
  const NearbyStation({required this.station, required this.distanceMeters});

  final RainStation station;
  final double distanceMeters;
}

class RouteAnalysis {
  const RouteAnalysis({
    required this.route,
    required this.nearbyStations,
    required this.observedRain,
    required this.forecastRain,
    required this.forecastProbability,
    required this.isFastest,
    required this.isRecommended,
    required this.hasHigherExposure,
  });

  final DrivingRoute route;

  final List<NearbyStation> nearbyStations;

  final double? observedRain;

  final double? forecastRain;

  final int? forecastProbability;

  final bool isFastest;
  final bool isRecommended;

  final bool hasHigherExposure;

  double get exposure => (observedRain ?? 0) + (forecastRain ?? 0);

  List<NearbyStation> get rainingStations =>
      nearbyStations.where((item) => item.station.isRaining).toList();

  String get label {
    if (isRecommended && isFastest) return 'Mais rápida e menor exposição';
    if (isRecommended) return 'Menor exposição à chuva';
    if (isFastest) return 'Mais rápida';
    return 'Alternativa';
  }
}

class RouteComparison {
  const RouteComparison({
    required this.routes,
    required this.recommendedIndex,
    required this.reason,
    required this.stationsAvailable,
    required this.forecastAvailable,
    required this.forecastHours,
    required this.radiusMeters,
    required this.checkedAt,
  });

  final List<RouteAnalysis> routes;
  final int recommendedIndex;

  final String reason;
  final bool stationsAvailable;
  final bool forecastAvailable;
  final int forecastHours;
  final double radiusMeters;
  final DateTime checkedAt;

  RouteAnalysis get recommended => routes[recommendedIndex];

  RouteAnalysis get fastest => routes.firstWhere((item) => item.isFastest);
}
