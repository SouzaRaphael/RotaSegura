import '../models/rain_station.dart';

enum StationFilter {
  all('Todas'),
  raining('Com chuva'),
  favorites('Favoritas');

  const StationFilter(this.label);

  final String label;
}

class StationQuery {
  const StationQuery._();

  static List<RainStation> apply(
    List<RainStation> stations, {
    required String search,
    required StationFilter filter,
    required Set<String> favorites,
  }) {
    final terms = _normalize(search).split(RegExp(r'\s+')).where((term) => term.isNotEmpty).toList();
    return stations.where((station) {
      if (!matches(station, filter, favorites)) return false;
      if (terms.isEmpty) return true;
      final text = _normalize('${station.name} ${station.basin} ${station.owner}');
      return terms.every(text.contains);
    }).toList();
  }

  static bool matches(RainStation station, StationFilter filter, Set<String> favorites) => switch (filter) {
    StationFilter.all => true,
    StationFilter.raining => station.isRaining,
    StationFilter.favorites => favorites.contains(station.id),
  };

  static int count(List<RainStation> stations, StationFilter filter, Set<String> favorites) =>
      stations.where((station) => matches(station, filter, favorites)).length;

  static String _normalize(String value) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final char in value.toLowerCase().split('')) {
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString();
  }
}
