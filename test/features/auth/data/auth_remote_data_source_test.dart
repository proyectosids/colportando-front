import 'package:colportando_app/core/config/app_config.dart';
import 'package:colportando_app/core/error/app_exception.dart';
import 'package:colportando_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final config = AppConfig(
    apiBaseUri: Uri.parse('https://api.example.test/api/v1/'),
  );

  test('login conserva el contrato de tokens del backend', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/login');
      expect(request.method, 'POST');
      return http.Response(
        '{"accessToken":"access","refreshToken":"refresh","tokenType":"Bearer","expiresIn":900}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final source = AuthRemoteDataSource(client, config);

    final result = await source.login(
      email: 'member@example.com',
      password: 'password-123',
      clientName: 'Test',
    );

    expect(result.accessToken, 'access');
    expect(result.refreshToken, 'refresh');
    expect(result.expiresIn, 900);
  });

  test('mapea el sobre de error y el correlationId', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"error":{"code":"INVALID_CREDENTIALS","message":"Invalid","correlationId":"trace-1"}}',
        401,
      ),
    );
    final source = AuthRemoteDataSource(client, config);

    expect(
      () => source.login(
        email: 'member@example.com',
        password: 'bad-password',
        clientName: 'Test',
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'INVALID_CREDENTIALS')
            .having((error) => error.correlationId, 'correlationId', 'trace-1'),
      ),
    );
  });
}
