class Formatters {
  const Formatters._();

  static const _saoPauloOffset = Duration(hours: -3);

  static DateTime toSaoPaulo(DateTime utc) => utc.toUtc().add(_saoPauloOffset);

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String time(DateTime utc) {
    final local = toSaoPaulo(utc);
    return '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String hourLabel(DateTime local) => '${_two(local.hour)}h';

  static String millimeters(double value) => '${decimal(value)} mm';

  static String decimal(double value, {int digits = 1}) {
    final text = value.toStringAsFixed(digits);
    final trimmed = text.contains('.') ? text.replaceFirst(RegExp(r'\.?0+$'), '') : text;
    return trimmed.replaceAll('.', ',');
  }

  static String minutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${_two(minutes % 60)} min';
  }

  static String minutesDifference(int difference) {
    if (difference == 0) return 'o mesmo tempo';
    return difference > 0 ? '$difference min a mais' : '${-difference} min a menos';
  }

  static String kilometers(double km) => '${decimal(km)} km';

  static String meters(double meters) =>
      meters < 1000 ? '${(meters / 10).round() * 10} m' : kilometers(meters / 1000);
}
