import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_preferences.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/register_notifier.dart';
import '../notifiers/profile_update_notifier.dart';
import '../notifiers/profile_update_with_image_notifier.dart';
import '../notifiers/current_user_notifier.dart';
import '../state/auth_state.dart';
import '../../domain/entities/preference.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../data/services/auth_image_service.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Image Services
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

final authImageServiceProvider = Provider<AuthImageService>((ref) {
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  return AuthImageService(imageUploadService: imageUploadService);
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

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final getPreferencesUseCaseProvider = Provider<GetPreferencesUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetPreferencesUseCase(repository);
});

// Notifiers/StateNotifiers
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((
  ref,
) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return LoginNotifier(loginUseCase: loginUseCase);
});

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
      final registerUseCase = ref.watch(registerUseCaseProvider);
      return RegisterNotifier(registerUseCase: registerUseCase);
    });

final profileUpdateNotifierProvider =
    StateNotifierProvider<ProfileUpdateNotifier, ProfileUpdateState>((ref) {
      final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
      return ProfileUpdateNotifier(updateProfileUseCase: updateProfileUseCase);
    });

final profileUpdateWithImageNotifierProvider =
    StateNotifierProvider<ProfileUpdateWithImageNotifier, ProfileUpdateState>((
      ref,
    ) {
      final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
      final authImageService = ref.watch(authImageServiceProvider);
      return ProfileUpdateWithImageNotifier(
        updateProfileUseCase: updateProfileUseCase,
        authImageService: authImageService,
      );
    });

final currentUserNotifierProvider =
    StateNotifierProvider<CurrentUserNotifier, CurrentUserState>((ref) {
      final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
      return CurrentUserNotifier(getCurrentUserUseCase: getCurrentUserUseCase);
    });

// Additional providers
final preferencesProvider = FutureProvider<List<Preference>>((ref) async {
  final getPreferencesUseCase = ref.watch(getPreferencesUseCaseProvider);
  final result = await getPreferencesUseCase(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (preferences) => preferences,
  );
});

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.isLoggedIn();

  return result.fold((failure) => false, (isLoggedIn) => isLoggedIn);
});
