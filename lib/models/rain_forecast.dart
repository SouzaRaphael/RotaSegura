import 'dart:math' as math;

class HourlyRain {
  const HourlyRain({required this.time, required this.precipitation, this.probability});

  final DateTime time;

  final double precipitation;

  final int? probability;
}

class RainForecast {
  const RainForecast({required this.latitude, required this.longitude, required this.hours});

  final double latitude;
  final double longitude;
  final List<HourlyRain> hours;

  factory RainForecast.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) throw const FormatException('Previsão sem dados horários.');
    final times = hourly['time'] as List<dynamic>? ?? const [];
    final rain = hourly['precipitation'] as List<dynamic>? ?? const [];
    final probability = hourly['precipitation_probability'] as List<dynamic>? ?? const [];
    final hours = <HourlyRain>[];
    for (var i = 0; i < times.length && i < rain.length; i++) {
      final time = DateTime.tryParse('${times[i]}');
      final value = rain[i];
      if (time == null || value is! num) continue;
      hours.add(
        HourlyRain(
          time: time,
          precipitation: value.toDouble(),
          probability: i < probability.length && probability[i] is num ? (probability[i] as num).round() : null,
        ),
      );
    }
    return RainForecast(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      hours: hours,
    );
  }

  double totalFor(int count) => hours.take(count).fold(0.0, (sum, hour) => sum + hour.precipitation);

  int maxProbabilityFor(int count) =>
      hours.take(count).fold(0, (value, hour) => math.max(value, hour.probability ?? 0));
}
