-- Apply this SQL to your Supabase database to fix the thumb up/down feedback issue
-- This allows feedback without marking the reading as completed

-- 1. Update the get_today_reading function to only consider readings with completed_at as completed
CREATE OR REPLACE FUNCTION get_today_reading(user_id UUID, target_day INTEGER DEFAULT NULL)
RETURNS TABLE (
  reading_id UUID,
  subject_id UUID,
  subject_name VARCHAR,
  day_sequence INTEGER,
  title VARCHAR,
  content TEXT,
  key_insight TEXT,
  tomorrow_hint TEXT,
  read_time_minutes INTEGER,
  created_at TIMESTAMP WITH TIME ZONE,
  is_completed BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dr.id as reading_id,
    dr.subject_id,
    rs.name as subject_name,
    dr.day_sequence,
    dr.title,
    dr.content,
    dr.key_insight,
    dr.tomorrow_hint,
    dr.read_time_minutes,
    dr.created_at,
    (rc.id IS NOT NULL AND rc.completed_at IS NOT NULL) as is_completed
  FROM public.daily_readings dr
  JOIN public.reading_subjects rs ON dr.subject_id = rs.id
  JOIN public.users u ON u.preference_id = rs.preference_id
  LEFT JOIN public.user_reading_progress urp ON urp.user_id = u.id AND urp.subject_id = rs.id
  LEFT JOIN public.reading_completions rc ON rc.user_id = u.id AND rc.reading_id = dr.id
  WHERE u.id = get_today_reading.user_id
    AND rs.is_active = true
    AND dr.day_sequence = COALESCE(target_day, COALESCE(urp.current_day, 1))
  ORDER BY rs.created_at
  LIMIT 1;
END;
$$;

-- 2. Add new function to record feedback without completing
CREATE OR REPLACE FUNCTION record_reading_feedback(
  p_user_id UUID,
  p_reading_id UUID,
  p_was_helpful BOOLEAN,
  p_user_note TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Insert into reading_feedback table (create a separate table for feedback only)
  -- Or update the existing reading_completions table but don't mark as completed
  
  -- For now, we'll use a simpler approach: just insert/update in reading_completions
  -- but with a special flag or null completion date to indicate it's just feedback
  INSERT INTO public.reading_completions (user_id, reading_id, was_helpful, user_note, completed_at)
  VALUES (p_user_id, p_reading_id, p_was_helpful, p_user_note, NULL)
  ON CONFLICT (user_id, reading_id) DO UPDATE SET
    was_helpful = EXCLUDED.was_helpful,
    user_note = EXCLUDED.user_note,
    -- Don't update completed_at, keep it NULL for feedback-only records
    completed_at = CASE 
      WHEN public.reading_completions.completed_at IS NOT NULL 
      THEN public.reading_completions.completed_at  -- Keep existing completion date
      ELSE NULL  -- Keep as NULL for feedback-only
    END;
  
  -- Return success response
  SELECT json_build_object(
    'success', true,
    'message', 'Feedback recorded successfully',
    'was_helpful', p_was_helpful
  ) INTO v_result;
  
  RETURN v_result;
END;
$$;
