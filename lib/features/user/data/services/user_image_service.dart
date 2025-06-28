import '../../../../core/services/image_upload_service.dart';
import '../../../../core/utils/logger.dart';

class UserImageService {
  final ImageUploadService _imageUploadService;

  UserImageService(this._imageUploadService);

  /// Upload user avatar and return the public URL
  Future<String> uploadAvatar({
    required String userId,
    required String imagePath,
  }) async {
    AppLogger.info(
      'Uploading avatar for user: $userId',
      tag: 'UserImageService',
    );

    try {
      final imageUrl = await _imageUploadService.uploadAvatar(
        userId: userId,
        filePath: imagePath,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload avatar');
      }

      AppLogger.info('Avatar uploaded successfully', tag: 'UserImageService');
      return imageUrl;
    } catch (e) {
      AppLogger.error(
        'Error uploading avatar',
        tag: 'UserImageService',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete user avatar from storage
  Future<void> deleteAvatar({required String avatarUrl}) async {
    AppLogger.info('Deleting avatar: $avatarUrl', tag: 'UserImageService');

    try {
      await _imageUploadService.deleteAvatar(avatarUrl);

      AppLogger.info('Avatar deleted successfully', tag: 'UserImageService');
    } catch (e) {
      AppLogger.error(
        'Error deleting avatar',
        tag: 'UserImageService',
        error: e,
      );
      rethrow;
    }
  }
}
