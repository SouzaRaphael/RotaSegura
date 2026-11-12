import '../../config/api_config.dart';
import '../../models/rain_station.dart';
import 'api_client.dart';

class RainStationService {
  RainStationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<RainStation>> fetchStations() async {
    final data = await _client.getJson(ApiConfig.rainStations);
    final measurements = data is Map<String, dynamic> ? data['measurements'] : null;
    if (measurements is! List) {
      throw const ApiException('A resposta do SIBH não trouxe medições.');
    }
    final stations = <RainStation>[];
    for (final item in measurements.whereType<Map<String, dynamic>>()) {
      if ('${item['cod_ibge']}' != RainStation.saoPauloIbgeCode) continue;
      if ('${item['station_name']}'.toLowerCase().contains('radar')) continue;
      try {
        stations.add(RainStation.fromJson(item));
      } on FormatException {
        continue;
      }
    }
    if (stations.isEmpty) {
      throw const ApiException('Nenhuma estação de São Paulo enviou medições válidas agora.');
    }
    stations.sort((a, b) {
      final byRain = b.rainfall.compareTo(a.rainfall);
      return byRain != 0 ? byRain : a.name.compareTo(b.name);
    });
    return stations;
  }
}
