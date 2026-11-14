
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> postJson(
    String endpoint,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    try {
      return await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'El servidor está tardando en responder. Puede estar iniciándose; espera un momento y vuelve a intentarlo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con HoodVoice. Comprueba que tengas Internet e inténtalo nuevamente.',
      );
    }
  }

  void close() => _client.close();
}
