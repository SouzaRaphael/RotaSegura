import 'package:latlong2/latlong.dart';

import '../../config/api_config.dart';
import '../../models/rain_forecast.dart';
import 'api_client.dart';

class ForecastService {
  ForecastService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<RainForecast>> fetchForecasts(List<LatLng> points, {int hours = 12}) async {
    if (points.isEmpty) return const [];
    final uri = Uri.https(ApiConfig.openMeteoHost, '/v1/forecast', {
      'latitude': points.map((point) => point.latitude.toStringAsFixed(4)).join(','),
      'longitude': points.map((point) => point.longitude.toStringAsFixed(4)).join(','),
      'hourly': 'precipitation,precipitation_probability',
      'forecast_hours': '$hours',
      'timezone': 'America/Sao_Paulo',
    });
    final data = await _client.getJson(uri);
    final items = data is List ? data : [data];
    try {
      final forecasts = items.whereType<Map<String, dynamic>>().map(RainForecast.fromJson).toList();
      if (forecasts.length != points.length) throw const FormatException('Quantidade de pontos diferente.');
      return forecasts;
    } on FormatException {
      throw const ApiException('A previsão do tempo veio incompleta.');
    }
  }

  Future<RainForecast> fetchForecast(LatLng point, {int hours = 12}) async =>
      (await fetchForecasts([point], hours: hours)).single;
}
