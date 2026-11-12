import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rota_segura/services/api/api_client.dart';
import 'package:rota_segura/services/api/rain_station_service.dart';
import 'package:rota_segura/services/station_filter.dart';
import 'package:rota_segura/utils/formatters.dart';

import '../support/fixtures.dart';

void main() {
  group('RainStationService', () {
    RainStationService serviceFor(http.Response response) =>
        RainStationService(client: ApiClient(client: MockClient((_) async => response)));

    test('mantém só estações válidas de São Paulo, da mais chuvosa para a menos', () async {
      final body = jsonEncode({
        'measurements': [
          sibhMeasurement(id: '1', value: 0.4),
          sibhMeasurement(id: '2', value: 17.6),
          sibhMeasurement(id: '3', ibge: '3556354'),
          sibhMeasurement(id: '4', name: 'São Paulo (Precipitação Radar Bacia do Capivari)'),
          sibhMeasurement(id: '5', value: 'inválido'),
        ],
      });
      final stations = await serviceFor(http.Response.bytes(utf8.encode(body), 200)).fetchStations();
      expect(stations.map((station) => station.id), ['2', '1']);
    });

    test('troca falhas técnicas por mensagens para o usuário', () async {
      await expectLater(
        serviceFor(http.Response('erro', 503)).fetchStations(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('indisponível'))),
      );
      await expectLater(
        serviceFor(http.Response('<html>', 200)).fetchStations(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('resposta inválida'))),
      );
    });
  });

  group('StationQuery', () {
    final stations = [
      station(id: '1', name: 'Água Funda', rainfall: 3),
      station(id: '2', name: 'Penha', rainfall: 0),
      station(id: '3', name: 'Lapa', rainfall: 1),
    ];

    test('busca sem diferenciar acentos e maiúsculas', () {
      final result = StationQuery.apply(stations, search: 'agua', filter: StationFilter.all, favorites: {});
      expect(result.single.name, 'Água Funda');
    });

    test('filtra estações com chuva e favoritas', () {
      expect(StationQuery.count(stations, StationFilter.raining, {}), 2);
      final favorites = StationQuery.apply(stations, search: '', filter: StationFilter.favorites, favorites: {'2'});
      expect(favorites.single.name, 'Penha');
    });
  });

  test('Formatters usa vírgula decimal e horário de Brasília', () {
    expect(Formatters.millimeters(12.0), '12 mm');
    expect(Formatters.millimeters(0.6), '0,6 mm');
    expect(Formatters.time(DateTime.utc(2026, 11, 12, 11, 50)), '08:50');
    expect(Formatters.minutes(75), '1 h 15 min');
    expect(Formatters.meters(840), '840 m');
  });
}
