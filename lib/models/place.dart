import 'package:latlong2/latlong.dart';

class Place {
  const Place({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LatLng get point => LatLng(latitude, longitude);

  factory Place.fromNominatim(Map<String, dynamic> json) {
    final latitude = double.tryParse('${json['lat']}');
    final longitude = double.tryParse('${json['lon']}');
    if (latitude == null || longitude == null) {
      throw const FormatException('Local sem coordenadas.');
    }
    final displayName = (json['display_name'] as String? ?? '').trim();
    final parts = displayName.split(', ');
    final name = (json['name'] as String? ?? '').trim();
    return Place(
      name: name.isNotEmpty ? name : parts.first,
      address: _shortAddress(parts, skipFirst: name.isEmpty || parts.first == name),
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _shortAddress(List<String> parts, {required bool skipFirst}) {
    const ignored = {'Brasil', 'Região Sudeste', 'Região Metropolitana de São Paulo', 'Região Imediata de São Paulo'};
    final useful = parts
        .skip(skipFirst ? 1 : 0)
        .where((part) => !ignored.contains(part) && !RegExp(r'^\d{5}-?\d{3}$').hasMatch(part))
        .toList();
    return useful.take(4).join(', ');
  }

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'] as String,
    address: json['address'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };

  bool isSameLocation(Place other) =>
      (latitude - other.latitude).abs() < 0.0002 && (longitude - other.longitude).abs() < 0.0002;
}
