import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_preferences.dart';

class PreferencesStorage {
  const PreferencesStorage();

  static const _key = 'app_preferences';

  Future<AppPreferences> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return const AppPreferences();
    try {
      return AppPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const AppPreferences();
    }
  }

  Future<void> save(AppPreferences preferences) async =>
      (await SharedPreferences.getInstance()).setString(_key, jsonEncode(preferences.toJson()));

  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
