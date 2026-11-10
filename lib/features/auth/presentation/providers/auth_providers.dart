import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/secure_token_storage.dart';
import '../../data/datasources/token_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_actions.dart';
import '../../domain/usecases/authenticate_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/validate_session.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(
    const FlutterSecureStorage(aOptions: AndroidOptions()),
  ),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(
    ref.watch(httpClientProvider),
    ref.watch(appConfigProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final authenticateUserProvider = Provider<AuthenticateUser>(
  (ref) => AuthenticateUser(ref.watch(authRepositoryProvider)),
);

final restoreSessionProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final validateSessionProvider = Provider<ValidateSession>(
  (ref) => ValidateSession(ref.watch(authRepositoryProvider)),
);

final logoutUserProvider = Provider<LogoutUser>(
  (ref) => LogoutUser(ref.watch(authRepositoryProvider)),
);

final authActionsProvider = Provider<AuthActions>(
  (ref) => AuthActions(ref.watch(authRepositoryProvider)),
);
