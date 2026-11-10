import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

final class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);

  static const _refreshTokenKey = 'colportando.auth.refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<void> clearRefreshToken() => _storage.delete(key: _refreshTokenKey);
}
