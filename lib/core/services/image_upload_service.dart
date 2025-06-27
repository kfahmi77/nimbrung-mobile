import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Reusable image upload service for Supabase storage
/// Can be used across different features (auth, posts, etc.)
class ImageUploadService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Upload image to specified bucket and folder
  /// 
  /// [bucketName] - The storage bucket name (e.g., 'avatars', 'posts')
  /// [folderPath] - Optional folder path within bucket (e.g., 'userId', 'posts/userId')
  /// [fileName] - The filename to use, or null to auto-generate
  /// [filePath] - Local file path (for mobile)
  /// [bytes] - File bytes (for web/memory)
  /// [filePrefix] - Prefix for auto-generated filename (e.g., 'avatar', 'post')
  Future<String?> uploadImage({
    required String bucketName,
    String? folderPath,
    String? fileName,
    String? filePath,
    Uint8List? bytes,
    String filePrefix = 'image',
  }) async {
    try {
      // Validate inputs
      if (filePath == null && bytes == null) {
        throw ArgumentError('Either filePath or bytes must be provided');
      }

      AppLogger.info(
        'Starting image upload to bucket: $bucketName',
        tag: 'ImageUploadService',
      );

      // Generate filename if not provided
      String finalFileName;
      if (fileName != null) {
        finalFileName = fileName;
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        String extension = 'jpg'; // default
        
        if (filePath != null) {
          extension = filePath.split('.').last.toLowerCase();
        }
        
        finalFileName = '${filePrefix}_$timestamp.$extension';
      }

      // Add folder path if provided
      final fullPath = folderPath != null 
          ? '$folderPath/$finalFileName' 
          : finalFileName;

      // Upload file to Supabase storage
      if (bytes != null) {
        // Upload from bytes (web/mobile)
        await _client.storage.from(bucketName).uploadBinary(fullPath, bytes);
      } else if (filePath != null) {
        // Upload from file path (mobile)
        final file = File(filePath);
        await _client.storage.from(bucketName).upload(fullPath, file);
      }

      // Get public URL
      final publicUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(fullPath);

      AppLogger.info(
        'Image uploaded successfully: $publicUrl',
        tag: 'ImageUploadService',
      );

      return publicUrl;
    } catch (e) {
      AppLogger.error(
        'Image upload failed: $e',
        tag: 'ImageUploadService',
        error: e,
      );
      return null;
    }
  }

  /// Upload avatar specifically (convenience method)
  Future<String?> uploadAvatar({
    required String userId,
    required String filePath,
    Uint8List? bytes,
  }) async {
    return uploadImage(
      bucketName: 'avatars',
      folderPath: userId,
      filePath: filePath,
      bytes: bytes,
      filePrefix: 'avatar',
    );
  }

  /// Upload post image (convenience method)
  Future<String?> uploadPostImage({
    required String userId,
    required String postId,
    required String filePath,
    Uint8List? bytes,
  }) async {
    return uploadImage(
      bucketName: 'posts',
      folderPath: '$userId/$postId',
      filePath: filePath,
      bytes: bytes,
      filePrefix: 'post',
    );
  }

  /// Delete image from storage
  Future<bool> deleteImage({
    required String bucketName,
    required String imageUrl,
  }) async {
    try {
      // Extract relative path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucketName);
      
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final relativePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(bucketName).remove([relativePath]);
      } else {
        // Fallback to just filename if path parsing fails
        final fileName = pathSegments.last;
        await _client.storage.from(bucketName).remove([fileName]);
      }

      AppLogger.info(
        'Image deleted successfully from: $imageUrl',
        tag: 'ImageUploadService',
      );

      return true;
    } catch (e) {
      AppLogger.error(
        'Error deleting image: $e',
        tag: 'ImageUploadService',
        error: e,
      );
      return false;
    }
  }

  /// Delete avatar specifically (convenience method)
  Future<bool> deleteAvatar(String avatarUrl) async {
    return deleteImage(bucketName: 'avatars', imageUrl: avatarUrl);
  }

  /// Create bucket if it doesn't exist
  Future<void> createBucket({
    required String bucketName,
    bool isPublic = true,
    List<String>? allowedMimeTypes,
    String? fileSizeLimit,
  }) async {
    try {
      await _client.storage.createBucket(
        bucketName,
        BucketOptions(
          public: isPublic,
          allowedMimeTypes: allowedMimeTypes ?? [
            'image/jpeg', 
            'image/png', 
            'image/webp',
            'image/gif'
          ],
          fileSizeLimit: fileSizeLimit ?? '10MB',
        ),
      );
      AppLogger.info('Bucket "$bucketName" created', tag: 'ImageUploadService');
    } catch (e) {
      // Bucket might already exist, which is fine
      AppLogger.debug('Bucket creation: $e', tag: 'ImageUploadService');
    }
  }

  /// Initialize common buckets (call this once during app initialization)
  Future<void> initializeCommonBuckets() async {
    // Avatar bucket for user profile pictures
    await createBucket(
      bucketName: 'avatars',
      isPublic: true,
      allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
      fileSizeLimit: '5MB',
    );

    // Posts bucket for post images
    await createBucket(
      bucketName: 'posts',
      isPublic: true,
      allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
      fileSizeLimit: '10MB',
    );
  }
}
