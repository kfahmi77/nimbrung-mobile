# DAILY READING DISCUSSION FEATURE IMPLEMENTATION PLAN

## Overview

Fitur diskusi untuk bacaan harian akan memungkinkan pengguna untuk berdiskusi tentang materi bacaan yang telah mereka baca. Setiap bacaan harian akan memiliki ruang diskusi tersendiri dengan thread yang terorganisir.

## Architecture Design

### 1. Database Schema

#### Table: reading_discussions

```sql
CREATE TABLE reading_discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reading_id UUID REFERENCES daily_readings(id) NOT NULL,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  is_pinned BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  total_comments INTEGER DEFAULT 0,
  total_participants INTEGER DEFAULT 0,
  last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Table: discussion_comments

```sql
CREATE TABLE discussion_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES reading_discussions(id) NOT NULL,
  parent_comment_id UUID REFERENCES discussion_comments(id), -- for nested replies
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  content TEXT NOT NULL,
  is_expert_comment BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  replies_count INTEGER DEFAULT 0,
  is_pinned BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Table: comment_likes

```sql
CREATE TABLE comment_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  comment_id UUID REFERENCES discussion_comments(id) NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(comment_id, user_id)
);
```

#### Table: discussion_participants

```sql
CREATE TABLE discussion_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES reading_discussions(id) NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  role VARCHAR(20) DEFAULT 'participant', -- participant, moderator, expert
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(discussion_id, user_id)
);
```

### 2. Domain Entities

#### ReadingDiscussion Entity

```dart
class ReadingDiscussion {
  final String id;
  final String readingId;
  final String createdBy;
  final String title;
  final String? description;
  final bool isPinned;
  final bool isLocked;
  final int totalComments;
  final int totalParticipants;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? creator; // populated from join
  final List<UserProfile>? recentParticipants; // populated from join

  const ReadingDiscussion({...});
}
```

#### DiscussionComment Entity

```dart
class DiscussionComment {
  final String id;
  final String discussionId;
  final String? parentCommentId;
  final String userId;
  final String content;
  final bool isExpertComment;
  final int likesCount;
  final int repliesCount;
  final bool isPinned;
  final bool isDeleted;
  final bool isLikedByUser; // populated from join
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? user; // populated from join
  final List<DiscussionComment>? replies; // populated from join

  const DiscussionComment({...});
}
```

### 3. Use Cases

#### Discussion Use Cases

- `GetReadingDiscussion` - Mendapatkan diskusi untuk reading tertentu
- `CreateDiscussionComment` - Membuat komentar baru
- `ReplyToComment` - Membalas komentar
- `LikeComment` - Like/unlike komentar
- `GetDiscussionComments` - Mendapatkan komentar dengan pagination
- `UpdateComment` - Edit komentar (jika diizinkan)
- `DeleteComment` - Hapus komentar (jika diizinkan)
- `PinComment` - Pin komentar (untuk moderator)
- `JoinDiscussion` - Bergabung ke diskusi
- `GetDiscussionParticipants` - Mendapatkan daftar partisipan

### 4. RPC Functions

#### Get Discussion for Reading

```sql
CREATE OR REPLACE FUNCTION get_reading_discussion(
  p_reading_id UUID,
  p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discussion JSON;
BEGIN
  SELECT json_build_object(
    'id', rd.id,
    'reading_id', rd.reading_id,
    'title', rd.title,
    'description', rd.description,
    'total_comments', rd.total_comments,
    'total_participants', rd.total_participants,
    'last_activity_at', rd.last_activity_at,
    'created_at', rd.created_at,
    'creator', json_build_object(
      'username', u.username,
      'fullname', u.fullname,
      'avatar', u.avatar
    ),
    'user_role', COALESCE(dp.role, 'guest')
  ) INTO v_discussion
  FROM public.reading_discussions rd
  JOIN public.users u ON rd.created_by = u.id
  LEFT JOIN public.discussion_participants dp ON dp.discussion_id = rd.id AND dp.user_id = p_user_id
  WHERE rd.reading_id = p_reading_id;

  -- If no discussion exists, create one automatically
  IF v_discussion IS NULL THEN
    INSERT INTO public.reading_discussions (reading_id, created_by, title)
    VALUES (p_reading_id, p_user_id, 'Diskusi Bacaan')
    RETURNING json_build_object(
      'id', id,
      'reading_id', reading_id,
      'title', title,
      'total_comments', 0,
      'total_participants', 0,
      'created_at', created_at,
      'user_role', 'participant'
    ) INTO v_discussion;
  END IF;

  RETURN v_discussion;
END;
$$;
```

#### Get Discussion Comments

```sql
CREATE OR REPLACE FUNCTION get_discussion_comments(
  p_discussion_id UUID,
  p_user_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  comment_data JSON
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT json_build_object(
    'id', dc.id,
    'discussion_id', dc.discussion_id,
    'parent_comment_id', dc.parent_comment_id,
    'content', dc.content,
    'is_expert_comment', dc.is_expert_comment,
    'likes_count', dc.likes_count,
    'replies_count', dc.replies_count,
    'is_pinned', dc.is_pinned,
    'is_liked_by_user', (cl.id IS NOT NULL),
    'created_at', dc.created_at,
    'user', json_build_object(
      'id', u.id,
      'username', u.username,
      'fullname', u.fullname,
      'avatar', u.avatar
    )
  ) as comment_data
  FROM public.discussion_comments dc
  JOIN public.users u ON dc.user_id = u.id
  LEFT JOIN public.comment_likes cl ON cl.comment_id = dc.id AND cl.user_id = p_user_id
  WHERE dc.discussion_id = p_discussion_id
    AND dc.parent_comment_id IS NULL
    AND dc.is_deleted = false
  ORDER BY dc.is_pinned DESC, dc.created_at ASC
  LIMIT p_limit OFFSET p_offset;
END;
$$;
```

### 5. UI Components Architecture

#### Navigation Integration

- Tambahkan tombol "Ikut Nimbrung" di `DailyReadingDetailScreen`
- Tombol akan membuka `ReadingDiscussionScreen`

#### Screen Structure

```dart
// screens/reading_discussion_screen.dart
class ReadingDiscussionScreen extends StatefulWidget {
  final String readingId;
  final String readingTitle;

  const ReadingDiscussionScreen({
    required this.readingId,
    required this.readingTitle,
  });
}
```

#### Widget Components

```dart
// widgets/discussion/
├── reading_discussion_header.dart     // Header dengan info bacaan
├── discussion_stats_card.dart         // Statistik diskusi
├── discussion_comment_item.dart       // Item komentar individual
├── comment_reply_item.dart            // Item reply
├── comment_input_field.dart           // Input untuk komentar baru
├── comment_actions_bar.dart           // Like, reply, share actions
├── participants_preview.dart          // Preview partisipan aktif
└── expert_badge.dart                  // Badge untuk komentar expert
```

### 6. State Management (Riverpod)

#### Providers

```dart
// providers/discussion_providers.dart

// Get discussion for reading
final readingDiscussionProvider = FutureProvider.family<ReadingDiscussion?, String>((ref, readingId) async {
  final useCase = ref.read(getReadingDiscussionUseCaseProvider);
  return await useCase(readingId);
});

// Get comments with pagination
final discussionCommentsProvider = StateNotifierProvider.family<DiscussionCommentsNotifier, AsyncValue<List<DiscussionComment>>, String>((ref, discussionId) {
  return DiscussionCommentsNotifier(ref.read(getDiscussionCommentsUseCaseProvider), discussionId);
});

// Comment creation state
final createCommentProvider = StateNotifierProvider<CreateCommentNotifier, AsyncValue<void>>((ref) {
  return CreateCommentNotifier(ref.read(createDiscussionCommentUseCaseProvider));
});
```

### 7. Integration Points

#### Dari Daily Reading Detail Screen

```dart
// Di DailyReadingDetailScreen, tambahkan button:
ElevatedButton.icon(
  onPressed: () {
    context.pushNamed(
      'reading-discussion',
      pathParameters: {
        'readingId': reading.readingId,
      },
      extra: {
        'readingTitle': reading.title,
      },
    );
  },
  icon: Icon(Icons.forum),
  label: Text('Ikut Nimbrung'),
)
```

#### Router Configuration

```dart
// Tambahkan route di app_router.dart
GoRoute(
  name: 'reading-discussion',
  path: '/reading/:readingId/discussion',
  builder: (context, state) {
    final readingId = state.pathParameters['readingId']!;
    final extra = state.extra as Map<String, dynamic>?;

    return ReadingDiscussionScreen(
      readingId: readingId,
      readingTitle: extra?['readingTitle'] ?? 'Diskusi Bacaan',
    );
  },
)
```

### 8. Features untuk Masa Depan

#### Phase 1: Basic Discussion

- ✅ Basic commenting system
- ✅ Like/unlike comments
- ✅ Reply to comments
- ✅ User profiles in comments

#### Phase 2: Enhanced Interaction

- 🔄 Real-time updates with WebSocket
- 🔄 Push notifications untuk replies
- 🔄 Mention system (@username)
- 🔄 Rich text formatting
- 🔄 Image/file attachments

#### Phase 3: Community Features

- 🔄 Expert verification system
- 🔄 Moderation tools
- 🔄 Comment reporting
- 🔄 Discussion analytics
- 🔄 Gamification (points, badges)

#### Phase 4: Advanced Features

- 🔄 AI-powered discussion insights
- 🔄 Related discussions suggestions
- 🔄 Discussion summaries
- 🔄 Voice comments
- 🔄 Live discussion sessions

### 9. Security Considerations

#### RLS Policies

```sql
-- Discussion comments policy
CREATE POLICY "Users can view discussion comments" ON discussion_comments
  FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON discussion_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON discussion_comments
  FOR UPDATE USING (auth.uid() = user_id);

-- Comment likes policy
CREATE POLICY "Users can like comments" ON comment_likes
  FOR ALL USING (auth.uid() = user_id);
```

#### Content Moderation

- Automatic content filtering
- User reporting system
- Expert/moderator review system
- Spam detection

### 10. Performance Optimizations

#### Database Optimizations

- Proper indexing on discussion_id, user_id
- Pagination for comments
- Caching frequently accessed discussions
- Background jobs for statistics updates

#### Client Optimizations

- Lazy loading untuk replies
- Image/avatar caching
- Infinite scroll untuk comments
- Optimistic updates untuk likes

## Implementation Priority

1. **Database Schema** (Week 1)
2. **Core RPC Functions** (Week 1-2)
3. **Domain Entities & Use Cases** (Week 2)
4. **Basic UI Components** (Week 3)
5. **Navigation Integration** (Week 3)
6. **State Management** (Week 4)
7. **Testing & Bug Fixes** (Week 4)
8. **Performance Optimization** (Week 5)

## File Structure

```
lib/features/discussions/
├── domain/
│   ├── entities/
│   │   ├── reading_discussion.dart
│   │   ├── discussion_comment.dart
│   │   └── comment_like.dart
│   ├── repositories/
│   │   └── discussion_repository.dart
│   └── usecases/
│       ├── get_reading_discussion.dart
│       ├── get_discussion_comments.dart
│       ├── create_discussion_comment.dart
│       ├── like_comment.dart
│       └── reply_to_comment.dart
├── data/
│   ├── models/
│   │   ├── reading_discussion_model.dart
│   │   ├── discussion_comment_model.dart
│   │   └── comment_like_model.dart
│   ├── datasources/
│   │   └── discussion_remote_data_source.dart
│   └── repositories/
│       └── discussion_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── discussion_providers.dart
    ├── screens/
    │   └── reading_discussion_screen.dart
    └── widgets/
        ├── discussion_header.dart
        ├── comment_item.dart
        ├── comment_input.dart
        └── participants_list.dart
```

## Conclusion

Arsitektur ini mengikuti clean architecture pattern yang sudah digunakan di proyek, dengan extensibility untuk fitur-fitur advanced di masa depan. Implementasi dapat dilakukan secara bertahap sesuai prioritas bisnis.
