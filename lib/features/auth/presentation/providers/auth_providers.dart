import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/get_current_user.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/register_notifier.dart';
import '../notifiers/app_auth_notifier.dart';
import '../state/auth_state.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// Notifiers/StateNotifiers
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((
  ref,
) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return LoginNotifier(loginUseCase: loginUseCase, ref: ref);
});

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
      final registerUseCase = ref.watch(registerUseCaseProvider);
      return RegisterNotifier(registerUseCase: registerUseCase, ref: ref);
    });

// User-related providers have been moved to lib/features/user/presentation/providers/user_providers.dart

// App-wide authentication provider
final appAuthNotifierProvider =
    StateNotifierProvider<AppAuthNotifier, AppAuthState>((ref) {
      final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
      final logoutUseCase = ref.watch(logoutUseCaseProvider);
      return AppAuthNotifier(
        getCurrentUserUseCase: getCurrentUserUseCase,
        logoutUseCase: logoutUseCase,
      );
    });

// Preferences provider has been moved to lib/features/user/presentation/providers/user_providers.dart

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.isLoggedIn();

  return result.fold((failure) => false, (isLoggedIn) => isLoggedIn);
});
