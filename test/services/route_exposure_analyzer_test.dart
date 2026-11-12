import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:rota_segura/services/analysis/geo_utils.dart';
import 'package:rota_segura/services/analysis/route_exposure_analyzer.dart';

import '../support/fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 11, 12, 12, 10);
  final north = route(points: const [LatLng(-23.55, -46.70), LatLng(-23.55, -46.60)], minutes: 20);
  final south = route(points: const [LatLng(-23.60, -46.70), LatLng(-23.60, -46.60)], minutes: 26);
  const analyzer = RouteExposureAnalyzer(radiusMeters: 2000);

  test('distância até a linha usa o segmento mais próximo', () {
    final distance = GeoUtils.distanceToPolylineMeters(const LatLng(-23.56, -46.65), north.points);
    expect(distance, closeTo(1112, 15));
  });

  test('recomenda a rota com menos chuva observada perto do trajeto', () {
    final comparison = analyzer.compare(
      routes: [north, south],
      stations: [station(id: 'a', rainfall: 12, point: const LatLng(-23.551, -46.65))],
      forecastsByRoute: null,
      now: now,
    );
    expect(comparison.recommendedIndex, 1);
    expect(comparison.routes[0].isFastest, isTrue);
    expect(comparison.routes[0].hasHigherExposure, isTrue);
    expect(comparison.routes[0].observedRain, 12);
    expect(comparison.routes[1].observedRain, 0);
    expect(comparison.reason, contains('6 min a mais'));
    expect(comparison.forecastAvailable, isFalse);
  });

  test('com exposição equivalente, recomenda a mais rápida', () {
    final comparison = analyzer.compare(
      routes: [south, north],
      stations: [station(rainfall: 0.2, point: const LatLng(-23.551, -46.65))],
      forecastsByRoute: [
        [forecast([0, 0, 0])],
        [forecast([0, 0, 0])],
      ],
      now: now,
    );
    expect(comparison.recommendedIndex, 1);
    expect(comparison.recommended.isFastest, isTrue);
    expect(comparison.routes[0].hasHigherExposure, isFalse);
  });

  test('considera a previsão do tempo de cada rota', () {
    final comparison = analyzer.compare(
      routes: [north, south],
      stations: const [],
      forecastsByRoute: [
        [forecast([0, 0, 0])],
        [forecast([3, 4, 5], probability: 90)],
      ],
      now: now,
    );
    expect(comparison.recommendedIndex, 0);
    expect(comparison.routes[1].forecastRain, 12);
    expect(comparison.routes[1].forecastProbability, 90);
  });

  test('ignora estações com leitura antiga', () {
    final comparison = analyzer.compare(
      routes: [north],
      stations: [station(rainfall: 30, point: const LatLng(-23.551, -46.65), end: DateTime.utc(2026, 11, 12, 9))],
      forecastsByRoute: null,
      now: now,
    );
    expect(comparison.routes.single.nearbyStations, isEmpty);
  });

  test('sem nenhuma fonte de chuva, explica que ordenou pelo tempo', () {
    final comparison = analyzer.compare(routes: [south, north], stations: null, forecastsByRoute: null, now: now);
    expect(comparison.recommendedIndex, 1);
    expect(comparison.reason, contains('apenas pelo tempo'));
  });
}
