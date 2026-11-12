import 'place.dart';

class SavedRoute {
  const SavedRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.weekdays,
    this.departureTime,
  });

  static const weekdayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  final String id;
  final String name;
  final Place origin;
  final Place destination;

  final List<int> weekdays;

  final String? departureTime;

  String get weekdaysLabel {
    if (weekdays.length == 7) return 'Todos os dias';
    if (weekdays.length == 5 && weekdays.every((day) => day <= 5)) return 'Dias úteis';
    return weekdays.map((day) => weekdayLabels[day - 1]).join(', ');
  }

  factory SavedRoute.fromJson(Map<String, dynamic> json) => SavedRoute(
    id: json['id'] as String,
    name: json['name'] as String,
    origin: Place.fromJson(json['origin'] as Map<String, dynamic>),
    destination: Place.fromJson(json['destination'] as Map<String, dynamic>),
    weekdays: (json['weekdays'] as List<dynamic>).map((day) => day as int).toList(),
    departureTime: json['departureTime'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'origin': origin.toJson(),
    'destination': destination.toJson(),
    'weekdays': weekdays,
    'departureTime': departureTime,
  };
}
