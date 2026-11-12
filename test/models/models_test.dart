import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/models/driving_route.dart';
import 'package:rota_segura/models/place.dart';
import 'package:rota_segura/models/rain_forecast.dart';
import 'package:rota_segura/models/rain_level.dart';
import 'package:rota_segura/models/rain_station.dart';
import 'package:rota_segura/models/saved_route.dart';

import '../support/fixtures.dart';

void main() {
  group('RainStation.fromJson', () {
    test('converte texto em números e limpa o nome', () {
      final station = RainStation.fromJson(sibhMeasurement());
      expect(station.id, '136');
      expect(station.name, 'G9 - Rio Cipó');
      expect(station.latitude, -23.56);
      expect(station.rainfall, 4.4);
      expect(station.readings, 7);
      expect(station.level, RainLevel.light);
      expect(station.periodEnd, DateTime.utc(2026, 11, 12, 11, 50));
    });

    test('arredonda ruído de ponto flutuante', () {
      expect(RainStation.fromJson(sibhMeasurement(value: 0.6000000000000001)).rainfall, 0.6);
    });

    test('rejeita medição sem valor ou coordenada', () {
      expect(() => RainStation.fromJson(sibhMeasurement(value: 'x')), throwsFormatException);
      expect(() => RainStation.fromJson(sibhMeasurement(latitude: '')), throwsFormatException);
      expect(() => RainStation.fromJson(sibhMeasurement(value: -1)), throwsFormatException);
    });

    test('marca leituras com mais de 90 minutos como antigas', () {
      final station = RainStation.fromJson(sibhMeasurement());
      expect(station.isStale(DateTime.utc(2026, 11, 12, 13, 0)), isFalse);
      expect(station.isStale(DateTime.utc(2026, 11, 12, 13, 30)), isTrue);
    });
  });

  test('RainLevel segue a escala do CGE', () {
    expect(RainLevel.fromMillimeters(0), RainLevel.none);
    expect(RainLevel.fromMillimeters(4.9), RainLevel.light);
    expect(RainLevel.fromMillimeters(5), RainLevel.moderate);
    expect(RainLevel.fromMillimeters(30), RainLevel.heavy);
    expect(RainLevel.fromMillimeters(60), RainLevel.veryHeavy);
  });

  test('Place.fromNominatim separa nome e endereço curto', () {
    final place = Place.fromNominatim({
      'name': 'Hospital das Clínicas',
      'lat': '-23.5570321',
      'lon': '-46.6700259',
      'display_name':
          'Hospital das Clínicas, 225, Avenida Doutor Eneas Carvalho de Aguiar, Cerqueira César, '
          'São Paulo, Região Sudeste, 05403-000, Brasil',
    });
    expect(place.name, 'Hospital das Clínicas');
    expect(place.address, '225, Avenida Doutor Eneas Carvalho de Aguiar, Cerqueira César, São Paulo');
    expect(Place.fromJson(place.toJson()).isSameLocation(place), isTrue);
  });

  test('DrivingRoute.fromOsrm inverte longitude/latitude', () {
    final route = DrivingRoute.fromOsrm({
      'distance': 2268.4,
      'duration': 254.7,
      'geometry': {
        'coordinates': [
          [-46.65, -23.56],
          [-46.67, -23.55],
        ],
      },
      'legs': [
        {'summary': 'Avenida Paulista, Rua da Consolação'},
      ],
    });
    expect(route.points.first.latitude, -23.56);
    expect(route.minutes, 4);
    expect(route.summary, 'Avenida Paulista, Rua da Consolação');
  });

  test('RainForecast.fromJson soma as primeiras horas', () {
    final forecast = RainForecast.fromJson({
      'latitude': -23.5,
      'longitude': -46.6,
      'hourly': {
        'time': ['2026-11-12T08:00', '2026-11-12T09:00', '2026-11-12T10:00'],
        'precipitation': [0.2, 1.3, 8.8],
        'precipitation_probability': [18, 29, 100],
      },
    });
    expect(forecast.hours, hasLength(3));
    expect(forecast.totalFor(2), closeTo(1.5, 0.001));
    expect(forecast.maxProbabilityFor(3), 100);
  });

  test('SavedRoute descreve os dias e volta do JSON', () {
    final saved = SavedRoute(
      id: '1',
      name: 'Casa → Trabalho',
      origin: const Place(name: 'Casa', address: '', latitude: -23.5, longitude: -46.6),
      destination: const Place(name: 'Trabalho', address: '', latitude: -23.6, longitude: -46.7),
      weekdays: const [1, 2, 3, 4, 5],
      departureTime: '08:00',
    );
    expect(saved.weekdaysLabel, 'Dias úteis');
    final copy = SavedRoute.fromJson(saved.toJson());
    expect(copy.name, saved.name);
    expect(copy.departureTime, '08:00');
  });
}
