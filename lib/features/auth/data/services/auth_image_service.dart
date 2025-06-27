import '../../../../core/services/image_upload_service.dart';
import '../../../../core/utils/logger.dart';

/// Auth-specific image service that uses the reusable ImageUploadService
class AuthImageService {
  final ImageUploadService _imageUploadService;

  AuthImageService({ImageUploadService? imageUploadService})
      : _imageUploadService = imageUploadService ?? ImageUploadService();

  /// Upload user avatar with auth-specific logic
  Future<String?> uploadUserAvatar({
    required String userId,
    required String filePath,
    dynamic bytes,
  }) async {
    try {
      AppLogger.info(
        'Uploading avatar for user: $userId',
        tag: 'AuthImageService',
      );

      // Use the reusable service
      final avatarUrl = await _imageUploadService.uploadAvatar(
        userId: userId,
        filePath: filePath,
        bytes: bytes,
      );

      if (avatarUrl != null) {
        AppLogger.info(
          'Avatar uploaded successfully for user: $userId',
          tag: 'AuthImageService',
        );
      }

      return avatarUrl;
    } catch (e) {
      AppLogger.error(
        'Failed to upload avatar for user: $userId',
        tag: 'AuthImageService',
        error: e,
      );
      return null;
    }
  }

  /// Delete user avatar with auth-specific logic
  Future<bool> deleteUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      AppLogger.info(
        'Deleting avatar for user: $userId',
        tag: 'AuthImageService',
      );

      // Use the reusable service
      final success = await _imageUploadService.deleteAvatar(avatarUrl);

      if (success) {
        AppLogger.info(
          'Avatar deleted successfully for user: $userId',
          tag: 'AuthImageService',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'Failed to delete avatar for user: $userId',
        tag: 'AuthImageService',
        error: e,
      );
      return false;
    }
  }

  /// Initialize avatar storage (call during auth module initialization)
  Future<void> initializeAvatarStorage() async {
    try {
      await _imageUploadService.createBucket(
        bucketName: 'avatars',
        isPublic: true,
        allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
        fileSizeLimit: '5MB',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to initialize avatar storage',
        tag: 'AuthImageService',
        error: e,
      );
    }
  }
}
