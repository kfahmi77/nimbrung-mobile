import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/update_profile.dart';
import '../state/auth_state.dart';

class ProfileUpdateNotifier extends StateNotifier<ProfileUpdateState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileUpdateNotifier({required UpdateProfileUseCase updateProfileUseCase})
    : _updateProfileUseCase = updateProfileUseCase,
      super(const ProfileUpdateInitial());

  Future<void> updateProfile({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
  }) async {
    AppLogger.info(
      'Starting profile update process',
      tag: 'ProfileUpdateNotifier',
    );

    state = const ProfileUpdateLoading();

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        userId: userId,
        bio: bio,
        birthPlace: birthPlace,
        dateBirth: dateBirth,
        preferenceId: preferenceId,
        avatar: avatar,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Profile update failed: ${failure.message}',
          tag: 'ProfileUpdateNotifier',
        );
        state = ProfileUpdateFailure(message: failure.message);
      },
      (user) {
        AppLogger.info(
          'Profile update successful',
          tag: 'ProfileUpdateNotifier',
        );
        state = ProfileUpdateSuccess(
          user: user,
          message: 'Profil berhasil diperbarui!',
        );
      },
    );
  }

  void resetState() {
    AppLogger.debug(
      'Resetting profile update state',
      tag: 'ProfileUpdateNotifier',
    );
    state = const ProfileUpdateInitial();
  }
}
