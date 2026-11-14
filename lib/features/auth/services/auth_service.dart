
import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      ApiConstants.loginEndpoint,
      {'username': username.trim(), 'password': password},
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        fallback: 'No fue posible iniciar sesión. Verifica tus datos.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida.');
      }
      final user = AuthResponse.fromJson(decoded);
      if (user.id.isEmpty || user.token.isEmpty) {
        throw const ApiException(
          'El servidor no devolvió los datos de sesión esperados.',
        );
      }
      return user;
    } on FormatException {
      throw const ApiException(
        'El servidor devolvió una respuesta de inicio de sesión no válida.',
      );
    }
  }

  Future<void> register(RegisterRequest requestData) async {
    final response = await _apiClient.postJson(
      ApiConstants.registerEndpoint,
      requestData.toJson(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        fallback: 'No fue posible crear la cuenta. Revisa los datos e inténtalo nuevamente.',
      );
    }
  }
}
