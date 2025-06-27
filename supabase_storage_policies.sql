-- Supabase Storage Policies for Multiple Buckets
-- Run these commands in your Supabase SQL Editor

-- First, make sure RLS is enabled on storage.objects (it should be by default)
-- If not, uncomment the next line:
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- =======================
-- AVATARS BUCKET POLICIES
-- =======================

-- Policy 1: Allow authenticated users to upload avatars to their own folder
CREATE POLICY "Allow users to upload avatars to their own folder" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow users to update avatars in their own folder
CREATE POLICY "Allow users to update their own avatars" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 3: Allow users to delete avatars from their own folder
CREATE POLICY "Allow users to delete their own avatars" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 4: Allow public read access to all avatars
-- This allows avatars to be displayed publicly in your app
CREATE POLICY "Allow public read access to avatars" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'avatars');

-- ===================
-- POSTS BUCKET POLICIES (Future feature)
-- ===================

-- Policy 5: Allow authenticated users to upload posts to their own folder
CREATE POLICY "Allow users to upload posts to their own folder" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'posts' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 6: Allow users to update posts in their own folder
CREATE POLICY "Allow users to update their own posts" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'posts' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 7: Allow users to delete posts from their own folder
CREATE POLICY "Allow users to delete their own posts" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'posts' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 8: Allow public read access to all posts
-- This allows post images to be displayed publicly in your app
CREATE POLICY "Allow public read access to posts" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'posts');

-- Alternative: If you want to restrict read access to authenticated users only
-- Uncomment these and comment out the public read policies above:
/*
CREATE POLICY "Allow authenticated read access to avatars" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated read access to posts" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'posts' AND auth.role() = 'authenticated');
*/

-- Check if policies were created successfully
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY policyname;
