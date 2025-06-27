import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/update_profile.dart';
import '../../data/services/auth_image_service.dart';
import '../state/auth_state.dart';

class ProfileUpdateWithImageNotifier extends StateNotifier<ProfileUpdateState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final AuthImageService _authImageService;

  ProfileUpdateWithImageNotifier({
    required UpdateProfileUseCase updateProfileUseCase,
    required AuthImageService authImageService,
  }) : _updateProfileUseCase = updateProfileUseCase,
       _authImageService = authImageService,
       super(const ProfileUpdateInitial());

  Future<void> updateProfileWithImage({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    File? avatarFile,
    String? existingAvatarUrl,
  }) async {
    AppLogger.info(
      'Starting profile update with image process',
      tag: 'ProfileUpdateWithImageNotifier',
    );

    state = const ProfileUpdateLoading();

    try {
      String? avatarUrl = existingAvatarUrl;

      // Upload new avatar if provided
      if (avatarFile != null) {
        AppLogger.info(
          'Uploading new avatar',
          tag: 'ProfileUpdateWithImageNotifier',
        );

        avatarUrl = await _authImageService.uploadUserAvatar(
          userId: userId,
          filePath: avatarFile.path,
        );

        if (avatarUrl == null) {
          state = const ProfileUpdateFailure(
            message: 'Gagal mengupload foto profil',
          );
          return;
        }

        // Delete old avatar if exists and is different
        if (existingAvatarUrl != null &&
            existingAvatarUrl.isNotEmpty &&
            existingAvatarUrl != avatarUrl) {
          _authImageService.deleteUserAvatar(
            userId: userId,
            avatarUrl: existingAvatarUrl,
          );
        }
      }

      // Update profile with avatar URL
      final result = await _updateProfileUseCase(
        UpdateProfileParams(
          userId: userId,
          bio: bio,
          birthPlace: birthPlace,
          dateBirth: dateBirth,
          preferenceId: preferenceId,
          avatar: avatarUrl,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error(
            'Profile update failed: ${failure.message}',
            tag: 'ProfileUpdateWithImageNotifier',
          );
          state = ProfileUpdateFailure(message: failure.message);
        },
        (user) {
          AppLogger.info(
            'Profile update successful',
            tag: 'ProfileUpdateWithImageNotifier',
          );
          state = ProfileUpdateSuccess(
            user: user,
            message: 'Profil berhasil diperbarui!',
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error during profile update: $e',
        tag: 'ProfileUpdateWithImageNotifier',
        error: e,
      );
      state = ProfileUpdateFailure(
        message: 'Terjadi kesalahan yang tidak terduga',
      );
    }
  }

  void resetState() {
    AppLogger.debug(
      'Resetting profile update state',
      tag: 'ProfileUpdateWithImageNotifier',
    );
    state = const ProfileUpdateInitial();
  }
}
