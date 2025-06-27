# Reusable Image Upload Service Architecture

## 📁 **Struktur yang Diimplementasikan:**

```
lib/
  core/
    services/
      image_upload_service.dart     # Reusable service untuk semua fitur
  features/
    auth/
      data/
        services/
          auth_image_service.dart   # Auth-specific service
    posts/                          # Future feature
      data/
        services/
          post_image_service.dart   # Post-specific service
```

## 🔄 **Arsitektur Reusable Service:**

### 1. Core Service (`ImageUploadService`)
- **Lokasi**: `lib/core/services/image_upload_service.dart`
- **Fungsi**: Upload, delete, bucket management
- **Reusable**: Bisa digunakan oleh semua fitur
- **Methods**:
  - `uploadImage()` - Generic upload method
  - `uploadAvatar()` - Convenience method untuk avatar
  - `uploadPostImage()` - Convenience method untuk post images
  - `deleteImage()` - Generic delete method
  - `createBucket()` - Bucket management
  - `initializeCommonBuckets()` - Initialize semua bucket

### 2. Feature-Specific Services
- **Auth**: `AuthImageService` - Wrapper untuk auth-specific logic
- **Posts**: `PostImageService` - Future wrapper untuk post images
- **Etc**: Service lain sesuai kebutuhan

## 📋 **Keuntungan Arsitektur Ini:**

### ✅ **Reusability**
```dart
// Auth feature
final authImageService = AuthImageService();
await authImageService.uploadUserAvatar(...);

// Posts feature (future)
final postImageService = PostImageService();
await postImageService.uploadPostImage(...);

// Direct usage (jika perlu)
final imageService = ImageUploadService();
await imageService.uploadImage(bucketName: 'custom', ...);
```

### ✅ **Maintainability**
- Core logic di satu tempat
- Update sekali, berlaku untuk semua fitur
- Clear separation of concerns

### ✅ **Flexibility**
- Support multiple buckets (`avatars`, `posts`, etc.)
- Support folder structure per user
- Configurable file size limits dan MIME types

### ✅ **Security**
- User-specific folders (`userId/avatar_timestamp.jpg`)
- Proper RLS policies
- Type-safe operations

## 🔧 **Implementasi:**

### Core Service Usage:
```dart
final imageService = ImageUploadService();

// Generic upload
final url = await imageService.uploadImage(
  bucketName: 'avatars',
  folderPath: userId,
  filePath: file.path,
  filePrefix: 'avatar',
);

// Convenience methods
final avatarUrl = await imageService.uploadAvatar(
  userId: userId,
  filePath: file.path,
);
```

### Feature-Specific Service Usage:
```dart
final authImageService = AuthImageService();

// Auth-specific upload dengan additional logic
final avatarUrl = await authImageService.uploadUserAvatar(
  userId: userId,
  filePath: file.path,
);
```

### Riverpod Integration:
```dart
// Core service provider
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

// Feature-specific provider
final authImageServiceProvider = Provider<AuthImageService>((ref) {
  final imageService = ref.watch(imageUploadServiceProvider);
  return AuthImageService(imageUploadService: imageService);
});
```

## 🗂️ **Bucket Structure:**

```
Supabase Storage:
  avatars/
    userId1/
      avatar_timestamp1.jpg
      avatar_timestamp2.png
    userId2/
      avatar_timestamp3.jpg
  
  posts/
    userId1/
      postId1/
        post_timestamp1.jpg
        post_timestamp2.png
      postId2/
        post_timestamp3.jpg
```

## 📚 **Migrations dari Structure Lama:**

### Before (Per-Feature):
```dart
// Auth feature
lib/features/auth/data/services/image_upload_service.dart

// Posts feature (duplicate code)
lib/features/posts/data/services/image_upload_service.dart
```

### After (Reusable):
```dart
// Core reusable service
lib/core/services/image_upload_service.dart

// Feature-specific wrappers
lib/features/auth/data/services/auth_image_service.dart
lib/features/posts/data/services/post_image_service.dart
```

## 🚀 **Usage dalam Different Features:**

### 1. User Profile (Auth)
```dart
final authImageService = ref.watch(authImageServiceProvider);
final avatarUrl = await authImageService.uploadUserAvatar(
  userId: user.id,
  filePath: selectedImage.path,
);
```

### 2. Post Images (Future Feature)
```dart
final postImageService = ref.watch(postImageServiceProvider);
final imageUrl = await postImageService.uploadPostImage(
  userId: user.id,
  postId: post.id,
  filePath: selectedImage.path,
);
```

### 3. Custom Usage
```dart
final imageService = ref.watch(imageUploadServiceProvider);
final url = await imageService.uploadImage(
  bucketName: 'custom-bucket',
  folderPath: 'special-folder',
  filePath: file.path,
  filePrefix: 'custom',
);
```

## 📝 **Best Practices:**

1. **Use Feature-Specific Services** untuk business logic
2. **Use Core Service** hanya jika perlu customization khusus
3. **Always use folder structure** untuk security (`userId/filename`)
4. **Initialize buckets** di app startup
5. **Handle errors gracefully** di setiap layer
6. **Log operations** untuk debugging

## 🔒 **Security Considerations:**

1. **RLS Policies** - Users hanya bisa akses folder mereka sendiri
2. **File Type Validation** - Restrict MIME types di bucket level
3. **File Size Limits** - Set appropriate limits per bucket
4. **Authentication** - Ensure user is authenticated before upload
5. **URL Parsing** - Proper path extraction untuk delete operations

Arsitektur ini memberikan balance yang baik antara reusability dan feature-specific needs, sambil mempertahankan clean architecture principles.
