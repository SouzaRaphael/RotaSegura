import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  const FavoritesStorage();

  static const _key = 'favorite_stations';

  Future<Set<String>> load() async =>
      ((await SharedPreferences.getInstance()).getStringList(_key) ?? const <String>[]).toSet();

  Future<Set<String>> toggle(String stationId) async {
    final favorites = await load();
    if (!favorites.remove(stationId)) favorites.add(stationId);
    await (await SharedPreferences.getInstance()).setStringList(_key, favorites.toList()..sort());
    return favorites;
  }

  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
