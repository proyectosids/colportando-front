import 'dart:convert';

import 'package:colportando_app/core/config/app_config.dart';
import 'package:colportando_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('consume los once contratos publicados de Authentication', () async {
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      final path = request.url.path;
      if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) {
        return _json(
          '{"accessToken":"access","refreshToken":"refresh-token-with-enough-length","tokenType":"Bearer","expiresIn":900}',
        );
      }
      if (path.endsWith('/auth/me')) {
        expect(request.headers['authorization'], 'Bearer access');
        return _json(
          '{"accountId":"22222222-2222-4222-8222-222222222222","email":"member@example.com","status":"ACTIVE","sessionId":"11111111-1111-4111-8111-111111111111"}',
        );
      }
      if (path.endsWith('/auth/invitations') && request.method == 'POST') {
        expect(request.headers['idempotency-key'], 'invite-example-001');
        return _json(
          '{"invitationId":"33333333-3333-4333-8333-333333333333","status":"PENDING","expiresAt":"2026-11-16T10:00:00.000Z","replayed":false}',
          status: 202,
        );
      }
      if (path.endsWith('/accept')) {
        expect(request.headers['idempotency-key'], 'accept-example-001');
        return _json(
          '{"accountId":"22222222-2222-4222-8222-222222222222","personId":"44444444-4444-4444-8444-444444444444","membershipId":"55555555-5555-4555-8555-555555555555","membershipStatus":"PENDING","memberCondition":"ASPIRANT","emailVerified":true,"replayed":false}',
          status: 201,
        );
      }
      if (path.endsWith('/auth/invitations/inspect') && request.method == 'POST') {
        return _json(
          '{"invitationId":"33333333-3333-4333-8333-333333333333","clubName":"Kerusso","institutionName":"ULV","emailHint":"me***@example.com","expiresAt":"2026-11-16T10:00:00.000Z"}',
        );
      }
      return http.Response('', 204);
    });
    final source = AuthRemoteDataSource(
      client,
      AppConfig(apiBaseUri: Uri.parse('https://api.example.test/api/v1/')),
    );

    await source.login(
      email: 'member@example.com',
      password: 'Valid-password-123!',
      clientName: 'Flutter',
    );
    await source.refresh('refresh-token-with-enough-length');
    await source.logout('refresh-token-with-enough-length');
    await source.me('access');
    await source.requestEmailVerification('member@example.com');
    await source.confirmEmailVerification(
      'member@example.com',
      '48271936',
    );
    await source.requestPasswordReset('member@example.com');
    await source.confirmPasswordReset(
      'member@example.com',
      '48271936',
      'New-password-123!',
    );
    await source.createInvitation(
      accessToken: 'access',
      clubId: '55555555-5555-4555-8555-555555555555',
      email: 'aspirant@example.com',
      idempotencyKey: 'invite-example-001',
    );
    await source.inspectInvitation('aspirant@example.com', 'K7M2P9Q4X6RT');
    await source.acceptInvitation(
      email: 'aspirant@example.com',
      code: 'K7M2P9Q4X6RT',
      password: 'Valid-password-123!',
      givenNames: 'Ana',
      familyName: 'López',
      idempotencyKey: 'accept-example-001',
    );

    expect(calls, hasLength(11));
    expect(
      calls,
      containsAll([
        'POST /api/v1/auth/login',
        'POST /api/v1/auth/refresh',
        'POST /api/v1/auth/logout',
        'GET /api/v1/auth/me',
        'POST /api/v1/auth/email-verification/request',
        'POST /api/v1/auth/email-verification/confirm',
        'POST /api/v1/auth/password-reset/request',
        'POST /api/v1/auth/password-reset/confirm',
        'POST /api/v1/auth/invitations',
        'POST /api/v1/auth/invitations/inspect',
        'POST /api/v1/auth/invitations/accept',
      ]),
    );
  });
}

http.Response _json(String body, {int status = 200}) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
