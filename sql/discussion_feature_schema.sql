-- DAILY READING DISCUSSION FEATURE - DATABASE SCHEMA
-- This creates tables and functions for discussion feature on daily readings

-- ============================================================================
-- DISCUSSION TABLES
-- ============================================================================

-- Main discussion table for each daily reading
CREATE TABLE IF NOT EXISTS reading_discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reading_id UUID REFERENCES daily_readings(id) NOT NULL,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  title VARCHAR(255) NOT NULL DEFAULT 'Diskusi Bacaan',
  description TEXT,
  is_pinned BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  total_comments INTEGER DEFAULT 0,
  total_participants INTEGER DEFAULT 0,
  last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(reading_id) -- One discussion per reading
);

-- Comments in discussions (supports nested replies)
CREATE TABLE IF NOT EXISTS discussion_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES reading_discussions(id) ON DELETE CASCADE NOT NULL,
  parent_comment_id UUID REFERENCES discussion_comments(id) ON DELETE CASCADE,
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

-- Comment likes (many-to-many)
CREATE TABLE IF NOT EXISTS comment_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  comment_id UUID REFERENCES discussion_comments(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(comment_id, user_id)
);

-- Discussion participants tracking
CREATE TABLE IF NOT EXISTS discussion_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES reading_discussions(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  role VARCHAR(20) DEFAULT 'participant', -- participant, moderator, expert
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(discussion_id, user_id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_reading_discussions_reading_id ON reading_discussions(reading_id);
CREATE INDEX IF NOT EXISTS idx_reading_discussions_created_by ON reading_discussions(created_by);
CREATE INDEX IF NOT EXISTS idx_reading_discussions_last_activity ON reading_discussions(last_activity_at DESC);

CREATE INDEX IF NOT EXISTS idx_discussion_comments_discussion_id ON discussion_comments(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_parent_id ON discussion_comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_user_id ON discussion_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_created_at ON discussion_comments(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comment_likes_comment_id ON comment_likes(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_user_id ON comment_likes(user_id);

CREATE INDEX IF NOT EXISTS idx_discussion_participants_discussion_id ON discussion_participants(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_participants_user_id ON discussion_participants(user_id);

-- ============================================================================
-- RPC FUNCTIONS FOR DISCUSSION FEATURE
-- ============================================================================

-- Get or create discussion for a reading
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
  v_discussion_id UUID;
  v_reading_title VARCHAR;
BEGIN
  -- Try to get existing discussion
  SELECT json_build_object(
    'id', rd.id,
    'reading_id', rd.reading_id,
    'title', rd.title,
    'description', rd.description,
    'is_pinned', rd.is_pinned,
    'is_locked', rd.is_locked,
    'total_comments', rd.total_comments,
    'total_participants', rd.total_participants,
    'last_activity_at', rd.last_activity_at,
    'created_at', rd.created_at,
    'creator', json_build_object(
      'id', u.id,
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
    -- Get reading title for discussion title
    SELECT dr.title INTO v_reading_title 
    FROM public.daily_readings dr 
    WHERE dr.id = p_reading_id;
    
    -- Insert new discussion
    INSERT INTO public.reading_discussions (reading_id, created_by, title)
    VALUES (p_reading_id, p_user_id, COALESCE('Diskusi: ' || v_reading_title, 'Diskusi Bacaan'))
    RETURNING id INTO v_discussion_id;
    
    -- Add creator as participant
    INSERT INTO public.discussion_participants (discussion_id, user_id, role)
    VALUES (v_discussion_id, p_user_id, 'participant');
    
    -- Return the newly created discussion
    SELECT json_build_object(
      'id', rd.id,
      'reading_id', rd.reading_id,
      'title', rd.title,
      'description', rd.description,
      'is_pinned', rd.is_pinned,
      'is_locked', rd.is_locked,
      'total_comments', rd.total_comments,
      'total_participants', rd.total_participants,
      'last_activity_at', rd.last_activity_at,
      'created_at', rd.created_at,
      'creator', json_build_object(
        'id', u.id,
        'username', u.username,
        'fullname', u.fullname,
        'avatar', u.avatar
      ),
      'user_role', 'participant'
    ) INTO v_discussion
    FROM public.reading_discussions rd
    JOIN public.users u ON rd.created_by = u.id
    WHERE rd.id = v_discussion_id;
  END IF;
  
  RETURN v_discussion;
END;
$$;

-- Get discussion comments with pagination
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
    'is_deleted', dc.is_deleted,
    'is_liked_by_user', (cl.id IS NOT NULL),
    'created_at', dc.created_at,
    'updated_at', dc.updated_at,
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
    AND dc.parent_comment_id IS NULL -- Only top-level comments
    AND dc.is_deleted = false
  ORDER BY dc.is_pinned DESC, dc.created_at ASC
  LIMIT p_limit OFFSET p_offset;
END;
$$;

-- Get replies for a specific comment
CREATE OR REPLACE FUNCTION get_comment_replies(
  p_comment_id UUID,
  p_user_id UUID,
  p_limit INTEGER DEFAULT 10,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  reply_data JSON
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
    'is_deleted', dc.is_deleted,
    'is_liked_by_user', (cl.id IS NOT NULL),
    'created_at', dc.created_at,
    'updated_at', dc.updated_at,
    'user', json_build_object(
      'id', u.id,
      'username', u.username,
      'fullname', u.fullname,
      'avatar', u.avatar
    )
  ) as reply_data
  FROM public.discussion_comments dc
  JOIN public.users u ON dc.user_id = u.id
  LEFT JOIN public.comment_likes cl ON cl.comment_id = dc.id AND cl.user_id = p_user_id
  WHERE dc.parent_comment_id = p_comment_id
    AND dc.is_deleted = false
  ORDER BY dc.created_at ASC
  LIMIT p_limit OFFSET p_offset;
END;
$$;

-- Create a new comment
CREATE OR REPLACE FUNCTION create_discussion_comment(
  p_discussion_id UUID,
  p_user_id UUID,
  p_content TEXT,
  p_parent_comment_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_comment_id UUID;
  v_result JSON;
BEGIN
  -- Insert the comment
  INSERT INTO public.discussion_comments (
    discussion_id, 
    user_id, 
    content, 
    parent_comment_id,
    is_expert_comment
  )
  VALUES (
    p_discussion_id, 
    p_user_id, 
    p_content, 
    p_parent_comment_id,
    -- Check if user is expert (has role 'expert' in this discussion)
    EXISTS(
      SELECT 1 FROM public.discussion_participants dp 
      WHERE dp.discussion_id = p_discussion_id 
      AND dp.user_id = p_user_id 
      AND dp.role = 'expert'
    )
  )
  RETURNING id INTO v_comment_id;
  
  -- Update parent comment replies count if this is a reply
  IF p_parent_comment_id IS NOT NULL THEN
    UPDATE public.discussion_comments 
    SET replies_count = replies_count + 1
    WHERE id = p_parent_comment_id;
  END IF;
  
  -- Update discussion total comments and last activity
  UPDATE public.reading_discussions 
  SET 
    total_comments = total_comments + 1,
    last_activity_at = NOW()
  WHERE id = p_discussion_id;
  
  -- Add user as participant if not already
  INSERT INTO public.discussion_participants (discussion_id, user_id, last_seen_at)
  VALUES (p_discussion_id, p_user_id, NOW())
  ON CONFLICT (discussion_id, user_id) 
  DO UPDATE SET last_seen_at = NOW();
  
  -- Update total participants count
  UPDATE public.reading_discussions 
  SET total_participants = (
    SELECT COUNT(DISTINCT user_id) 
    FROM public.discussion_participants 
    WHERE discussion_id = p_discussion_id
  )
  WHERE id = p_discussion_id;
  
  -- Return the created comment
  SELECT json_build_object(
    'id', dc.id,
    'discussion_id', dc.discussion_id,
    'parent_comment_id', dc.parent_comment_id,
    'content', dc.content,
    'is_expert_comment', dc.is_expert_comment,
    'likes_count', dc.likes_count,
    'replies_count', dc.replies_count,
    'is_pinned', dc.is_pinned,
    'is_deleted', dc.is_deleted,
    'is_liked_by_user', false, -- New comment, user hasn't liked it yet
    'created_at', dc.created_at,
    'updated_at', dc.updated_at,
    'user', json_build_object(
      'id', u.id,
      'username', u.username,
      'fullname', u.fullname,
      'avatar', u.avatar
    )
  ) INTO v_result
  FROM public.discussion_comments dc
  JOIN public.users u ON dc.user_id = u.id
  WHERE dc.id = v_comment_id;
  
  RETURN v_result;
END;
$$;

-- Like/unlike a comment
CREATE OR REPLACE FUNCTION toggle_comment_like(
  p_comment_id UUID,
  p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_is_liked BOOLEAN;
  v_likes_count INTEGER;
BEGIN
  -- Check if user already liked this comment
  SELECT EXISTS(
    SELECT 1 FROM public.comment_likes 
    WHERE comment_id = p_comment_id AND user_id = p_user_id
  ) INTO v_is_liked;
  
  IF v_is_liked THEN
    -- Unlike: remove the like
    DELETE FROM public.comment_likes 
    WHERE comment_id = p_comment_id AND user_id = p_user_id;
    
    -- Update comment likes count
    UPDATE public.discussion_comments 
    SET likes_count = likes_count - 1
    WHERE id = p_comment_id;
    
    v_is_liked := false;
  ELSE
    -- Like: add the like
    INSERT INTO public.comment_likes (comment_id, user_id)
    VALUES (p_comment_id, p_user_id);
    
    -- Update comment likes count
    UPDATE public.discussion_comments 
    SET likes_count = likes_count + 1
    WHERE id = p_comment_id;
    
    v_is_liked := true;
  END IF;
  
  -- Get updated likes count
  SELECT likes_count INTO v_likes_count
  FROM public.discussion_comments
  WHERE id = p_comment_id;
  
  RETURN json_build_object(
    'success', true,
    'is_liked', v_is_liked,
    'likes_count', v_likes_count
  );
END;
$$;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE reading_discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_participants ENABLE ROW LEVEL SECURITY;

-- Reading discussions policies
CREATE POLICY "Users can view all discussions" ON reading_discussions
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create discussions" ON reading_discussions
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Discussion creators can update their discussions" ON reading_discussions
  FOR UPDATE USING (auth.uid() = created_by);

-- Discussion comments policies
CREATE POLICY "Users can view non-deleted comments" ON discussion_comments
  FOR SELECT USING (is_deleted = false);

CREATE POLICY "Authenticated users can create comments" ON discussion_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Comment authors can update their comments" ON discussion_comments
  FOR UPDATE USING (auth.uid() = user_id);

-- Comment likes policies  
CREATE POLICY "Users can view all comment likes" ON comment_likes
  FOR SELECT USING (true);

CREATE POLICY "Users can manage their own likes" ON comment_likes
  FOR ALL USING (auth.uid() = user_id);

-- Discussion participants policies
CREATE POLICY "Users can view all participants" ON discussion_participants
  FOR SELECT USING (true);

CREATE POLICY "Users can manage their own participation" ON discussion_participants
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Function to update discussion last_activity_at when comments are added
CREATE OR REPLACE FUNCTION update_discussion_activity()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.reading_discussions 
  SET last_activity_at = NOW()
  WHERE id = NEW.discussion_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for discussion activity updates
DROP TRIGGER IF EXISTS trigger_update_discussion_activity ON discussion_comments;
CREATE TRIGGER trigger_update_discussion_activity
  AFTER INSERT ON discussion_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_discussion_activity();

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- This will be automatically created when users first access discussions
-- through the get_reading_discussion function

SELECT 'Discussion feature schema created successfully!' as status;
