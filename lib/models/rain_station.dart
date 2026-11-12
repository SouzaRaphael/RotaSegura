import 'package:latlong2/latlong.dart';

import 'rain_level.dart';

class RainStation {
  const RainStation({
    required this.id,
    required this.name,
    required this.owner,
    required this.basin,
    required this.latitude,
    required this.longitude,
    required this.rainfall,
    required this.readings,
    required this.periodStart,
    required this.periodEnd,
  });

  static const saoPauloIbgeCode = '3550308';

  static const staleAfter = Duration(minutes: 90);

  final String id;
  final String name;
  final String owner;
  final String basin;
  final double latitude;
  final double longitude;

  final double rainfall;

  final int readings;
  final DateTime periodStart;
  final DateTime periodEnd;

  LatLng get point => LatLng(latitude, longitude);

  RainLevel get level => RainLevel.fromMillimeters(rainfall);

  bool get isRaining => rainfall > 0;

  bool isStale(DateTime now) => now.difference(periodEnd) > staleAfter;

  factory RainStation.fromJson(Map<String, dynamic> json) {
    final latitude = double.tryParse('${json['latitude']}');
    final longitude = double.tryParse('${json['longitude']}');
    final value = json['value'];
    final start = DateTime.tryParse('${json['min_date']}');
    final end = DateTime.tryParse('${json['max_date']}');
    if (latitude == null || longitude == null || value is! num || !value.isFinite || value < 0) {
      throw const FormatException('Medição sem coordenadas ou valor válido.');
    }
    if (start == null || end == null) {
      throw const FormatException('Medição sem horário.');
    }
    return RainStation(
      id: '${json['station_prefix_id']}',
      name: cleanName('${json['station_name'] ?? ''}'),
      owner: '${json['station_owner'] ?? ''}'.trim(),
      basin: '${json['subugrhi_name'] ?? ''}'.trim(),
      latitude: latitude,
      longitude: longitude,
      rainfall: (value.toDouble() * 10).roundToDouble() / 10,
      readings: int.tryParse('${json['qtd']}') ?? 0,
      periodStart: start.toUtc(),
      periodEnd: end.toUtc(),
    );
  }

  static String cleanName(String raw) {
    var name = raw.replaceAll('�', '').trim();
    final match = RegExp(r'^São Paulo\s*\((.*)\)$').firstMatch(name);
    if (match != null) name = match.group(1)!.trim();
    return name.isEmpty ? 'Estação sem nome' : name;
  }
}
