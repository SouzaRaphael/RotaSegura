import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

class GeoUtils {
  const GeoUtils._();

  static const _earthRadius = 6371000.0;

  static double distanceMeters(LatLng a, LatLng b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) * math.pow(math.sin(dLon / 2), 2);
    return 2 * _earthRadius * math.asin(math.min(1, math.sqrt(h)));
  }

  static double distanceToPolylineMeters(LatLng point, List<LatLng> line) {
    if (line.isEmpty) return double.infinity;
    if (line.length == 1) return distanceMeters(point, line.first);
    final cosLat = math.cos(_rad(point.latitude));
    double x(LatLng p) => _rad(p.longitude - point.longitude) * cosLat * _earthRadius;
    double y(LatLng p) => _rad(p.latitude - point.latitude) * _earthRadius;

    var best = double.infinity;
    for (var i = 0; i < line.length - 1; i++) {
      final ax = x(line[i]), ay = y(line[i]), bx = x(line[i + 1]), by = y(line[i + 1]);
      final dx = bx - ax, dy = by - ay;
      final lengthSquared = dx * dx + dy * dy;
      final t = lengthSquared == 0 ? 0.0 : (((-ax) * dx + (-ay) * dy) / lengthSquared).clamp(0.0, 1.0);
      final px = ax + t * dx, py = ay + t * dy;
      best = math.min(best, math.sqrt(px * px + py * py));
    }
    return best;
  }

  static List<LatLng> samplePoints(List<LatLng> line, int count) {
    if (line.length <= count) return List.of(line);
    return List.generate(count, (i) => line[((line.length - 1) * i / (count - 1)).round()]);
  }

  static double _rad(double degrees) => degrees * math.pi / 180;
}
