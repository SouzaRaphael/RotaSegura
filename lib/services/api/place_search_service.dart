import '../../config/api_config.dart';
import '../../models/place.dart';
import 'api_client.dart';

class PlaceSearchService {
  PlaceSearchService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const minQueryLength = 3;

  Future<List<Place>> search(String query) async {
    final text = query.trim();
    if (text.length < minQueryLength) {
      throw const ApiException('Digite pelo menos 3 letras para buscar.');
    }
    final uri = Uri.https(ApiConfig.nominatimHost, '/search', {
      'q': text,
      'format': 'jsonv2',
      'limit': '10',
      'countrycodes': 'br',
      'accept-language': 'pt-BR',
      'viewbox':
          '${ApiConfig.saoPauloWest},${ApiConfig.saoPauloNorth},${ApiConfig.saoPauloEast},${ApiConfig.saoPauloSouth}',
      'bounded': '1',
    });
    final data = await _client.getJson(uri);
    if (data is! List) throw const ApiException('A busca de endereços enviou uma resposta inválida.');

    final places = <Place>[];
    for (final item in data.whereType<Map<String, dynamic>>()) {
      try {
        final place = Place.fromNominatim(item);
        final duplicated = places.any(
          (other) => other.name == place.name && (other.address == place.address || other.isSameLocation(place)),
        );
        if (ApiConfig.isInsideSaoPaulo(place.point) && !duplicated) places.add(place);
      } on FormatException {
        continue;
      }
    }
    return places;
  }
}
