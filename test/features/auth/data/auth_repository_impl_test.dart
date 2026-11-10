import 'package:colportando_app/core/config/app_config.dart';
import 'package:colportando_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:colportando_app/features/auth/data/datasources/token_storage.dart';
import 'package:colportando_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('restaura la sesión rotando y reemplazando el refresh token', () async {
    final storage = _MemoryTokenStorage('old-refresh-token');
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount += 1;
      if (request.url.path.endsWith('/auth/refresh')) {
        return http.Response(
          '{"accessToken":"new-access","refreshToken":"new-refresh","tokenType":"Bearer","expiresIn":900}',
          200,
        );
      }
      expect(request.headers['authorization'], 'Bearer new-access');
      return http.Response(
        '{"accountId":"22222222-2222-4222-8222-222222222222","email":"member@example.com","status":"ACTIVE","sessionId":"11111111-1111-4111-8111-111111111111"}',
        200,
      );
    });
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(
        client,
        AppConfig(apiBaseUri: Uri.parse('https://api.example.test/api/v1/')),
      ),
      storage,
    );

    final account = await repository.restoreSession();

    expect(account?.email, 'member@example.com');
    expect(storage.value, 'new-refresh');
    expect(requestCount, 2);
  });
}

final class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage(this.value);
  String? value;

  @override
  Future<void> clearRefreshToken() async => value = null;

  @override
  Future<String?> readRefreshToken() async => value;

  @override
  Future<void> writeRefreshToken(String token) async => value = token;
}
