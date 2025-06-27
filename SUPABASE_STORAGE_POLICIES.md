# Supabase Storage Policies for Avatar Upload

## Problem

Getting RLS (Row Level Security) policy error when uploading images:

```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

## Solution

You need to create a storage bucket and set up proper RLS policies in your Supabase dashboard.

## Step 1: Create Storage Bucket

1. Go to your Supabase Dashboard
2. Navigate to Storage > Buckets
3. Click "Create Bucket"
4. Bucket configuration:
   - **Name**: `avatars` (not `image-public/avatars`)
   - **Public**: Enable (checked)
   - **File size limit**: 5MB
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp`

## Step 2: Create RLS Policies

Go to Storage > Policies and create the following policies for the `avatars` bucket:

### Policy 1: Allow Authenticated Users to Upload

```sql
-- Policy Name: "Allow authenticated users to upload avatars"
-- Operation: INSERT
-- Target: objects
-- Policy Definition:
CREATE POLICY "Allow authenticated users to upload avatars" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
);
```

### Policy 2: Allow Users to Update Their Own Avatars

```sql
-- Policy Name: "Allow users to update their own avatars"
-- Operation: UPDATE
-- Target: objects
-- Policy Definition:
CREATE POLICY "Allow users to update their own avatars" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
);
```

### Policy 3: Allow Users to Delete Their Own Avatars

```sql
-- Policy Name: "Allow users to delete their own avatars"
-- Operation: DELETE
-- Target: objects
-- Policy Definition:
CREATE POLICY "Allow users to delete their own avatars" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
);
```

### Policy 4: Allow Public Read Access

```sql
-- Policy Name: "Allow public read access to avatars"
-- Operation: SELECT
-- Target: objects
-- Policy Definition:
CREATE POLICY "Allow public read access to avatars" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'avatars');
```

## Step 3: Update Your Flutter Code

Update the bucket name in your `ImageUploadService`:

```dart
class ImageUploadService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _bucketName = 'avatars'; // Changed from 'image-public/avatars'

  // ... rest of your code
}
```

## Alternative: More Restrictive Policies (Recommended)

If you want users to only access their own avatars, use these policies instead:

### Policy 1: Allow Users to Upload Their Own Avatars

```sql
CREATE POLICY "Allow users to upload their own avatars" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Policy 2: Allow Users to Update Their Own Avatars

```sql
CREATE POLICY "Allow users to update their own avatars" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Policy 3: Allow Users to Delete Their Own Avatars

```sql
CREATE POLICY "Allow users to delete their own avatars" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Policy 4: Allow Public Read Access

```sql
CREATE POLICY "Allow public read access to avatars" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'avatars');
```

And update your upload service to organize files by user ID:

```dart
Future<String?> uploadAvatar({
  required String userId,
  required String filePath,
  Uint8List? bytes,
}) async {
  try {
    // Generate unique filename with user folder
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = filePath.split('.').last.toLowerCase();
    final fileName = '$userId/avatar_$timestamp.$extension'; // User folder structure

    // ... rest of upload logic
  } catch (e) {
    // ... error handling
  }
}
```

## Step 4: Test the Setup

1. Make sure you're authenticated in your app
2. Try uploading an avatar
3. Check the Supabase Storage dashboard to see if the file was uploaded
4. Verify the public URL is accessible

## Troubleshooting

1. **Still getting 403 errors**: Make sure RLS is enabled on the bucket and policies are active
2. **Authentication issues**: Verify your user is properly authenticated before upload
3. **Bucket not found**: Ensure bucket name matches exactly in both Supabase and your code
4. **File size errors**: Check bucket file size limits
5. **MIME type errors**: Verify allowed MIME types in bucket settings

## SQL Commands Summary

Run these in your Supabase SQL Editor if you prefer:

```sql
-- Create policies for avatars bucket
-- Basic policies (allow all authenticated users)
CREATE POLICY "Allow authenticated users to upload avatars" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Allow users to update their own avatars" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Allow users to delete their own avatars" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Allow public read access to avatars" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'avatars');
```
