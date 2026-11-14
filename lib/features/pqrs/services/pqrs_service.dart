
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../models/pqrs_request.dart';

class PqrsService {
  Future<Map<String, dynamic>> crearPQRS({
    required PqrsRequest solicitud,
    required String token,
  }) async {
    if (solicitud.archivo != null) {
      final size = await solicitud.archivo!.length();
      if (size > ApiConstants.maxPhotoBytes) {
        throw const ApiException(
          'La fotografía supera el límite de 10 MB. Toma otra foto con menor resolución.',
        );
      }
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.createPqrsEndpoint}',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields.addAll({
        'tipo': solicitud.tipo,
        'descripcion': solicitud.descripcion.trim(),
        'usuarioId': solicitud.usuarioId,
      });

    if (solicitud.archivo != null) {
      final image = solicitud.archivo!;
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: image.name.isEmpty ? 'evidencia.jpg' : image.name,
        ),
      );
    }

    try {
      final streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          response,
          fallback: 'No se pudo registrar la PQRS.',
        );
      }

      if (response.body.trim().isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'respuesta': decoded.toString()};
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Tus datos y la fotografía siguen en el formulario; puedes reintentar.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con HoodVoice. Comprueba tu conexión a Internet. Tus datos y la fotografía siguen en el formulario para reintentar.',
      );
    } on FormatException {
      throw const ApiException(
        'El servidor recibió la solicitud, pero devolvió una respuesta que no pudimos interpretar.',
      );
    }
  }
}
