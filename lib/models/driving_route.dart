import 'package:latlong2/latlong.dart';

class DrivingRoute {
  const DrivingRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.summary,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  final String summary;

  int get minutes => (durationSeconds / 60).round();

  double get kilometers => distanceMeters / 1000;

  factory DrivingRoute.fromOsrm(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final coordinates = geometry is Map<String, dynamic> ? geometry['coordinates'] : null;
    final distance = json['distance'];
    final duration = json['duration'];
    if (coordinates is! List || coordinates.length < 2 || distance is! num || duration is! num) {
      throw const FormatException('Rota sem geometria ou resumo.');
    }
    final points = coordinates.map((item) {
      final pair = item as List<dynamic>;
      return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
    }).toList();
    final legs = json['legs'] as List<dynamic>? ?? const [];
    final summary = legs
        .map((leg) => (leg as Map<String, dynamic>)['summary'] as String? ?? '')
        .where((text) => text.trim().isNotEmpty)
        .join(', ');
    return DrivingRoute(
      points: points,
      distanceMeters: distance.toDouble(),
      durationSeconds: duration.toDouble(),
      summary: summary,
    );
  }
}
