import '../../config/api_config.dart';
import '../../models/driving_route.dart';
import '../../models/place.dart';
import 'api_client.dart';

class RoutingService {
  RoutingService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<DrivingRoute>> fetchRoutes(Place origin, Place destination) async {
    final coordinates =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final uri = Uri.https(ApiConfig.osrmHost, '/route/v1/driving/$coordinates', {
      'alternatives': '3',
      'overview': 'full',
      'geometries': 'geojson',
      'steps': 'true',
    });
    final data = await _client.getJson(uri);
    if (data is! Map<String, dynamic>) throw const ApiException('O serviço de rotas enviou uma resposta inválida.');
    if (data['code'] == 'NoRoute') {
      throw const ApiException('Não encontramos uma rota de carro entre esses locais.');
    }
    final routes = data['routes'];
    if (data['code'] != 'Ok' || routes is! List || routes.isEmpty) {
      throw const ApiException('O serviço de rotas não conseguiu calcular o trajeto.');
    }
    try {
      return routes.whereType<Map<String, dynamic>>().map(DrivingRoute.fromOsrm).toList();
    } on FormatException {
      throw const ApiException('O serviço de rotas enviou uma rota incompleta.');
    }
  }
}
