import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/notifiers/app_auth_notifier.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/datasources/user_remote_data_source_impl.dart';
import '../../data/services/user_image_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_avatar.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/search_users.dart';
import '../notifiers/user_profile_notifier.dart';
import '../notifiers/preference_notifier.dart';
import '../notifiers/user_search_notifier.dart';
import '../state/user_state.dart';
import '../state/preference_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/preference.dart';

// Data sources
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) => UserRemoteDataSourceImpl(),
);

// Services
final imageUploadServiceProvider = Provider<ImageUploadService>(
  (ref) => ImageUploadService(),
);

final userImageServiceProvider = Provider<UserImageService>(
  (ref) => UserImageService(ref.read(imageUploadServiceProvider)),
);

// Repository
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    remoteDataSource: ref.read(userRemoteDataSourceProvider),
    imageService: ref.read(userImageServiceProvider),
  ),
);

// Use cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => GetUserProfileUseCase(ref.read(userRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.read(userRepositoryProvider)),
);

final updateAvatarUseCaseProvider = Provider<UpdateAvatarUseCase>(
  (ref) => UpdateAvatarUseCase(ref.read(userRepositoryProvider)),
);

final getPreferencesUseCaseProvider = Provider<GetPreferencesUseCase>(
  (ref) => GetPreferencesUseCase(ref.read(userRepositoryProvider)),
);

final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>(
  (ref) => SearchUsersUseCase(ref.read(userRepositoryProvider)),
);

// Notifiers
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserState>(
      (ref) => UserProfileNotifier(
        ref.read(getUserProfileUseCaseProvider),
        ref.read(updateProfileUseCaseProvider),
        ref.read(updateAvatarUseCaseProvider),
      ),
    );

final preferenceNotifierProvider =
    StateNotifierProvider<PreferenceNotifier, PreferenceState>(
      (ref) => PreferenceNotifier(ref.read(getPreferencesUseCaseProvider)),
    );

final userSearchNotifierProvider =
    StateNotifierProvider<UserSearchNotifier, UserState>(
      (ref) => UserSearchNotifier(ref.read(searchUsersUseCaseProvider)),
    );

// Current user provider (helper) - integrates with auth state
final currentUserProvider = Provider<String?>((ref) {
  final authState = ref.watch(appAuthNotifierProvider);

  if (authState is AppAuthAuthenticated) {
    return authState.user.id;
  }

  return null;
});

// Preferences provider
final preferencesProvider = FutureProvider<List<Preference>>((ref) async {
  final getPreferencesUseCase = ref.watch(getPreferencesUseCaseProvider);
  final result = await getPreferencesUseCase(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (preferences) => preferences,
  );
});

// Current user profile provider - automatically loads user profile when authenticated
final currentUserProfileProvider = Provider<UserState>((ref) {
  final currentUserId = ref.watch(currentUserProvider);

  if (currentUserId != null) {
    // Trigger loading the user profile
    ref
        .watch(userProfileNotifierProvider.notifier)
        .getUserProfile(currentUserId);
  }

  return ref.watch(userProfileNotifierProvider);
});
