# Image Upload Feature Documentation

## Overview

This feature allows users to select and upload avatar images for their profile using either the camera or gallery, with automatic upload to Supabase storage.

## Implementation Details

### 1. Dependencies Added

```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.7 # For selecting images from camera/gallery
  permission_handler: ^11.3.0 # For handling permissions
```

### 2. Files Created/Modified

#### New Files:

- `lib/features/auth/data/services/image_upload_service.dart` - Handles Supabase storage operations
- `lib/presentation/widgets/enhanced_profile_photo_picker.dart` - Enhanced image picker widget
- `lib/features/auth/presentation/notifiers/profile_update_with_image_notifier.dart` - Handles profile updates with image

#### Modified Files:

- `pubspec.yaml` - Added dependencies
- `android/app/src/main/AndroidManifest.xml` - Added camera and storage permissions
- `ios/Runner/Info.plist` - Added camera and photo library permissions
- `lib/main.dart` - Initialize storage bucket
- `lib/features/auth/presentation/providers/auth_providers.dart` - Added image service provider
- `lib/features/auth/auth.dart` - Export new notifier
- `lib/presentation/screens/register_update/register_update_page.dart` - Use enhanced image picker

### 3. Features

#### Image Upload Service (`ImageUploadService`)

- Upload images to Supabase storage bucket named 'avatars'
- Generate unique filenames with timestamp
- Delete old avatars when updating
- Handle both file uploads and byte array uploads
- 5MB file size limit
- Supports JPEG, PNG, WEBP formats

#### Enhanced Profile Photo Picker

- Camera capture option
- Gallery selection option
- Remove photo option
- Preview selected image
- User-friendly bottom sheet interface
- Error handling with user feedback

#### Profile Update with Image

- Combines profile data update with image upload
- Handles image upload before profile update
- Automatic cleanup of old avatars
- Proper error handling and user feedback

### 4. Permissions Required

#### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take profile photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select profile photos</string>
```

### 5. Usage

#### In Register Update Page:

```dart
ProfilePhotoPicker(
  label: "Foto Profil",
  onImageSelected: (File? file) {
    setState(() {
      _selectedAvatarFile = file;
    });
  },
  initialImageUrl: currentUser?.avatar,
)
```

#### Profile Update with Image:

```dart
await ref.read(profileUpdateWithImageNotifierProvider.notifier)
  .updateProfileWithImage(
    userId: currentUserId,
    bio: bioText,
    birthPlace: birthPlace,
    dateBirth: dateBirth,
    preferenceId: preferenceId,
    avatarFile: selectedAvatarFile,
    existingAvatarUrl: currentUser?.avatar,
  );
```

### 6. Supabase Storage Setup

The app automatically creates an 'avatars' bucket with these settings:

- Public access enabled
- Allowed MIME types: image/jpeg, image/png, image/webp
- File size limit: 5MB

### 7. Error Handling

- Network errors during upload
- File size and format validation
- Permission denied scenarios
- Storage quota exceeded
- User-friendly error messages in Indonesian

### 8. Security Considerations

- File size limits to prevent abuse
- MIME type restrictions for security
- Unique filename generation to prevent conflicts
- Automatic cleanup of old files
- Public URLs but with obscure filenames

## Testing

1. **Camera Access**: Test taking photos with camera
2. **Gallery Access**: Test selecting from photo gallery
3. **Upload Process**: Verify successful uploads to Supabase
4. **Error Scenarios**: Test with no internet, large files, etc.
5. **Permissions**: Test permission requests and denials
6. **Avatar Display**: Verify uploaded avatars display correctly

## Next Steps

1. Add image compression for better performance
2. Add support for multiple image formats
3. Implement offline support with sync
4. Add image editing capabilities (crop, rotate)
5. Add avatar caching for better performance
