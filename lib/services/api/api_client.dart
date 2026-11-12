import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 20)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<dynamic> getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri, headers: const {'Accept': 'application/json'}).timeout(timeout);
    } on TimeoutException {
      throw const ApiException('O serviço demorou para responder. Verifique a conexão e tente novamente.');
    } on http.ClientException {
      throw const ApiException('Não foi possível conectar ao serviço. Verifique sua internet e tente novamente.');
    }

    if (response.statusCode == 429) {
      throw const ApiException('Muitas consultas seguidas. Aguarde alguns segundos e tente novamente.');
    }
    if (response.statusCode >= 500) {
      throw const ApiException('O serviço está indisponível no momento. Tente novamente mais tarde.');
    }
    if (response.statusCode != 200) {
      throw ApiException('O serviço recusou a consulta (código ${response.statusCode}).');
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } on FormatException {
      throw const ApiException('O serviço enviou uma resposta inválida.');
    }
  }
}
