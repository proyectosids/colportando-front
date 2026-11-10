import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../models/current_account_dto.dart';
import '../models/invitation_dto.dart';
import '../models/token_pair_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._config);

  final http.Client _client;
  final AppConfig _config;

  Future<TokenPairDto> login({
    required String email,
    required String password,
    required String clientName,
  }) async {
    final json = await _sendJson(
      method: 'POST',
      path: 'auth/login',
      body: {'email': email, 'password': password, 'clientName': clientName},
    );
    return TokenPairDto.fromJson(json!);
  }

  Future<TokenPairDto> refresh(String refreshToken) async {
    final json = await _sendJson(
      method: 'POST',
      path: 'auth/refresh',
      body: {'refreshToken': refreshToken},
    );
    return TokenPairDto.fromJson(json!);
  }

  Future<void> logout(String refreshToken) async {
    await _sendJson(
      method: 'POST',
      path: 'auth/logout',
      body: {'refreshToken': refreshToken},
    );
  }

  Future<CurrentAccountDto> me(String accessToken) async {
    final json = await _sendJson(
      method: 'GET',
      path: 'auth/me',
      accessToken: accessToken,
    );
    return CurrentAccountDto.fromJson(json!);
  }

  Future<void> requestPasswordReset(String email) async {
    await _sendJson(
      method: 'POST',
      path: 'auth/password-reset/request',
      body: {'email': email},
    );
  }

  Future<void> requestEmailVerification(String email) async {
    await _sendJson(
      method: 'POST',
      path: 'auth/email-verification/request',
      body: {'email': email},
    );
  }

  Future<void> confirmEmailVerification(String email, String code) async {
    await _sendJson(
      method: 'POST',
      path: 'auth/email-verification/confirm',
      body: {'email': email, 'code': code},
    );
  }

  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {
    await _sendJson(
      method: 'POST',
      path: 'auth/password-reset/confirm',
      body: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }

  Future<InvitationCreatedDto> createInvitation({
    required String accessToken,
    required String clubId,
    required String email,
    required String idempotencyKey,
  }) async {
    final json = await _sendJson(
      method: 'POST',
      path: 'auth/invitations',
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      body: {'clubId': clubId, 'email': email},
    );
    return InvitationCreatedDto.fromJson(json!);
  }

  Future<InvitationContextDto> inspectInvitation(String email, String code) async {
    final json = await _sendJson(
      method: 'POST',
      path: 'auth/invitations/inspect',
      body: {'email': email, 'code': code},
    );
    return InvitationContextDto.fromJson(json!);
  }

  Future<InvitationAcceptedDto> acceptInvitation({
    required String email,
    required String code,
    required String password,
    required String givenNames,
    required String familyName,
    required String idempotencyKey,
    String? secondFamilyName,
    String? phoneE164,
  }) async {
    final json = await _sendJson(
      method: 'POST',
      path: 'auth/invitations/accept',
      idempotencyKey: idempotencyKey,
      body: {
        'email': email,
        'code': code,
        'password': password,
        'givenNames': givenNames,
        'familyName': familyName,
        'secondFamilyName': ?secondFamilyName,
        'phoneE164': ?phoneE164,
      },
    );
    return InvitationAcceptedDto.fromJson(json!);
  }

  Future<Map<String, Object?>?> _sendJson({
    required String method,
    required String path,
    Map<String, Object?>? body,
    String? accessToken,
    String? idempotencyKey,
  }) async {
    try {
      final request = http.Request(method, _config.apiBaseUri.resolve(path));
      request.headers.addAll({
        'accept': 'application/json',
        if (body != null) 'content-type': 'application/json; charset=utf-8',
        if (accessToken != null) 'authorization': 'Bearer $accessToken',
        'idempotency-key': ?idempotencyKey,
      });
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _client
          .send(request)
          .timeout(_config.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = _decodeObject(response.bodyBytes);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded?['error'];
        final errorJson = error is Map<String, Object?> ? error : null;
        throw ApiException(
          statusCode: response.statusCode,
          code: errorJson?['code'] as String?,
          message:
              errorJson?['message'] as String? ?? 'La solicitud fue rechazada.',
          correlationId: errorJson?['correlationId'] as String?,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException('El servidor tardó demasiado en responder.');
    } on http.ClientException {
      throw const NetworkException('No fue posible conectar con el servidor.');
    } on FormatException {
      throw const NetworkException(
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }

  Map<String, Object?>? _decodeObject(List<int> bytes) {
    if (bytes.isEmpty) return null;
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, Object?>) {
      throw const FormatException('Expected a JSON object.');
    }
    return value;
  }
}
