import '../../../../core/error/app_exception.dart';
import '../../domain/entities/current_account.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/token_storage.dart';
import '../models/token_pair_dto.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  String? _accessToken;
  String? _refreshToken;
  Future<TokenPairDto>? _refreshInFlight;

  @override
  Future<CurrentAccount> login(LoginCredentials credentials) async {
    final tokens = await _remote.login(
      email: credentials.email.trim().toLowerCase(),
      password: credentials.password,
      clientName: credentials.clientName,
    );
    await _saveTokens(tokens);
    try {
      return (await _remote.me(tokens.accessToken)).toDomain();
    } catch (_) {
      await _clearTokens();
      rethrow;
    }
  }

  @override
  Future<CurrentAccount?> restoreSession() async {
    final storedRefreshToken = await _tokenStorage.readRefreshToken();
    if (storedRefreshToken == null) return null;
    _refreshToken = storedRefreshToken;

    try {
      final tokens = await _rotateRefreshToken();
      return (await _remote.me(tokens.accessToken)).toDomain();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) rethrow;
      await _clearTokens();
      return null;
    }
  }

  @override
  Future<CurrentAccount> validateSession() async {
    return _withAccess((token) async => (await _remote.me(token)).toDomain());
  }

  @override
  Future<void> logout() async {
    final token = _refreshToken ?? await _tokenStorage.readRefreshToken();
    try {
      if (token != null) await _remote.logout(token);
    } finally {
      await _clearTokens();
    }
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _remote.requestPasswordReset(email.trim().toLowerCase());

  @override
  Future<void> requestEmailVerification(String email) =>
      _remote.requestEmailVerification(email.trim().toLowerCase());

  @override
  Future<void> confirmEmailVerification(String email, String code) =>
      _remote.confirmEmailVerification(email.trim().toLowerCase(), code.trim());

  @override
  Future<void> confirmPasswordReset(String email, String code, String newPassword) =>
      _remote.confirmPasswordReset(email.trim().toLowerCase(), code.trim(), newPassword);

  @override
  Future<InvitationCreated> createInvitation({
    required String clubId,
    required String email,
    required String idempotencyKey,
  }) => _withAccess(
    (token) async => (await _remote.createInvitation(
      accessToken: token,
      clubId: clubId.trim(),
      email: email.trim().toLowerCase(),
      idempotencyKey: idempotencyKey,
    )).toDomain(),
  );

  @override
  Future<InvitationContext> inspectInvitation(String email, String code) async =>
      (await _remote.inspectInvitation(email.trim().toLowerCase(), code.trim())).toDomain();

  @override
  Future<InvitationAccepted> acceptInvitation(
    AcceptInvitationInput input,
  ) async => (await _remote.acceptInvitation(
    email: input.email.trim().toLowerCase(),
    code: input.code.trim(),
    password: input.password,
    givenNames: input.givenNames.trim(),
    familyName: input.familyName.trim(),
    idempotencyKey: input.idempotencyKey,
    secondFamilyName: input.secondFamilyName?.trim(),
    phoneE164: input.phoneE164?.trim(),
  )).toDomain();

  Future<T> _withAccess<T>(Future<T> Function(String token) operation) async {
    var token = _accessToken;
    token ??= (await _rotateRefreshToken()).accessToken;
    try {
      return await operation(token);
    } on ApiException catch (error) {
      if (!error.isUnauthorized) rethrow;
      final refreshed = await _rotateRefreshToken();
      return operation(refreshed.accessToken);
    }
  }

  Future<TokenPairDto> _rotateRefreshToken() async {
    final activeRefresh =
        _refreshToken ?? await _tokenStorage.readRefreshToken();
    if (activeRefresh == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'MISSING_REFRESH_TOKEN',
        message: 'No hay una sesión que se pueda renovar.',
      );
    }

    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final operation = _performRefresh(activeRefresh);
    _refreshInFlight = operation;
    try {
      return await operation;
    } finally {
      if (identical(_refreshInFlight, operation)) _refreshInFlight = null;
    }
  }

  Future<TokenPairDto> _performRefresh(String refreshToken) async {
    try {
      final tokens = await _remote.refresh(refreshToken);
      await _saveTokens(tokens);
      return tokens;
    } on ApiException catch (error) {
      if (error.isUnauthorized) await _clearTokens();
      rethrow;
    }
  }

  Future<void> _saveTokens(TokenPairDto tokens) async {
    _accessToken = tokens.accessToken;
    _refreshToken = tokens.refreshToken;
    await _tokenStorage.writeRefreshToken(tokens.refreshToken);
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _tokenStorage.clearRefreshToken();
  }
}
