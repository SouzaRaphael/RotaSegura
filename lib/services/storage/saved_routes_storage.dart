import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/place.dart';
import '../../models/saved_route.dart';

class SavedRoutesStorage {
  const SavedRoutesStorage();

  static const _key = 'saved_routes';
  static const maxRoutes = 20;

  Future<List<SavedRoute>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => SavedRoute.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Object {
      return [];
    }
  }

  Future<void> _write(List<SavedRoute> routes) async => (await SharedPreferences.getInstance()).setString(
    _key,
    jsonEncode(routes.map((route) => route.toJson()).toList()),
  );

  Future<SavedRoute> add({
    required String name,
    required Place origin,
    required Place destination,
    required Set<int> weekdays,
    String? departureTime,
  }) async {
    final nameError = validateName(name);
    if (nameError != null) throw ArgumentError(nameError);
    final daysError = validateWeekdays(weekdays);
    if (daysError != null) throw ArgumentError(daysError);

    final routes = await load();
    if (routes.length >= maxRoutes) {
      throw ArgumentError('Você pode guardar até $maxRoutes rotas. Exclua uma para salvar outra.');
    }
    final route = SavedRoute(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      origin: origin,
      destination: destination,
      weekdays: weekdays.toList()..sort(),
      departureTime: departureTime,
    );
    await _write([route, ...routes]);
    return route;
  }

  Future<List<SavedRoute>> remove(String id) async {
    final routes = (await load())..removeWhere((route) => route.id == id);
    await _write(routes);
    return routes;
  }

  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Dê um nome para a rota, por exemplo "Casa → Trabalho".';
    if (name.length < 3) return 'Use pelo menos 3 caracteres.';
    if (name.length > 40) return 'Use no máximo 40 caracteres.';
    return null;
  }

  static String? validateWeekdays(Set<int> weekdays) =>
      weekdays.isEmpty ? 'Escolha pelo menos um dia da semana.' : null;
}
