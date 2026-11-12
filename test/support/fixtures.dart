import 'package:latlong2/latlong.dart';
import 'package:rota_segura/models/driving_route.dart';
import 'package:rota_segura/models/rain_forecast.dart';
import 'package:rota_segura/models/rain_station.dart';

Map<String, dynamic> sibhMeasurement({
  String id = '136',
  String name = 'São Paulo (G9 - Rio Cipó)',
  String ibge = '3550308',
  Object value = 4.4,
  String latitude = '-23.5600',
  String longitude = '-46.6500',
  String end = '2026-11-12T11:50:00.000Z',
}) => {
  'station_prefix_id': id,
  'station_name': name,
  'cod_ibge': ibge,
  'station_owner': 'SABESP',
  'subugrhi_name': 'Guarapiranga',
  'latitude': latitude,
  'longitude': longitude,
  'value': value,
  'qtd': '7',
  'min_date': '2026-11-12T10:50:00.000Z',
  'max_date': end,
};

RainStation station({
  String id = '1',
  String name = 'Estação',
  double rainfall = 0,
  LatLng point = const LatLng(-23.56, -46.65),
  DateTime? end,
}) => RainStation(
  id: id,
  name: name,
  owner: 'DAEE',
  basin: 'Alto Tietê',
  latitude: point.latitude,
  longitude: point.longitude,
  rainfall: rainfall,
  readings: 6,
  periodStart: (end ?? DateTime.utc(2026, 11, 12, 12)).subtract(const Duration(hours: 1)),
  periodEnd: end ?? DateTime.utc(2026, 11, 12, 12),
);

DrivingRoute route({required List<LatLng> points, required double minutes}) =>
    DrivingRoute(points: points, distanceMeters: 5000, durationSeconds: minutes * 60, summary: 'Rua Teste');

RainForecast forecast(List<double> hours, {int probability = 50}) => RainForecast(
  latitude: -23.56,
  longitude: -46.65,
  hours: [
    for (var i = 0; i < hours.length; i++)
      HourlyRain(time: DateTime(2026, 11, 12, 9 + i), precipitation: hours[i], probability: probability),
  ],
);
