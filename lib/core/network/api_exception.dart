
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static ApiException fromResponse(
    http.Response response, {
    required String fallback,
  }) {
    final body = response.body.trim();
    var message = body;

    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          final candidate = decoded['mensaje'] ??
              decoded['message'] ??
              decoded['error'] ??
              decoded['detail'];
          if (candidate != null && candidate.toString().trim().isNotEmpty) {
            message = candidate.toString().trim();
          }
        }
      } on FormatException {
        // Algunos endpoints del backend responden texto plano.
      }
    }

    if (message.isEmpty) message = fallback;

    if (response.statusCode == 401) {
      message = 'Tu sesión no es válida o tus credenciales son incorrectas. $message';
    } else if (response.statusCode == 403) {
      message = 'No tienes autorización para realizar esta operación. $message';
    } else if (response.statusCode >= 500) {
      message = 'El servidor presentó un problema. Inténtalo nuevamente. $message';
    }

    return ApiException(message, statusCode: response.statusCode);
  }
}
