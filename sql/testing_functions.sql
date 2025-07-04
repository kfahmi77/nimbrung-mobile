-- TESTING FUNCTIONS FOR DAILY READING FEATURE
-- Apply these functions to your Supabase database to enable testing features

-- RPC function to simulate day change for testing
CREATE OR REPLACE FUNCTION simulate_day_change(
  p_user_id UUID,
  p_days_to_advance INTEGER DEFAULT 1
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_result JSON;
  v_subject_id UUID;
  v_new_day INTEGER;
  v_max_day INTEGER;
BEGIN
  -- Get user's active subject
  SELECT rs.id INTO v_subject_id
  FROM public.reading_subjects rs
  JOIN public.users u ON u.preference_id = rs.preference_id
  WHERE u.id = p_user_id AND rs.is_active = true
  ORDER BY rs.created_at
  LIMIT 1;
  
  IF v_subject_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'No active subject found for user'
    );
  END IF;
  
  -- Get max available day for this subject
  SELECT MAX(day_sequence) INTO v_max_day
  FROM public.daily_readings
  WHERE subject_id = v_subject_id;
  
  -- Update or insert user progress
  INSERT INTO public.user_reading_progress (user_id, subject_id, current_day, last_read_date)
  VALUES (p_user_id, v_subject_id, 1 + p_days_to_advance, CURRENT_DATE)
  ON CONFLICT (user_id, subject_id) DO UPDATE SET
    current_day = CASE 
      WHEN public.user_reading_progress.current_day + p_days_to_advance > v_max_day 
      THEN 1  -- Reset to day 1 if exceeds max
      ELSE public.user_reading_progress.current_day + p_days_to_advance
    END,
    last_read_date = CURRENT_DATE;
  
  -- Get the new current day
  SELECT current_day INTO v_new_day
  FROM public.user_reading_progress
  WHERE user_id = p_user_id AND subject_id = v_subject_id;
  
  SELECT json_build_object(
    'success', true,
    'message', 'Day advanced successfully',
    'new_day', v_new_day,
    'max_day', v_max_day,
    'reset_to_day_1', v_new_day = 1 AND p_days_to_advance > 0
  ) INTO v_result;
  
  RETURN v_result;
END;
$$;

-- RPC function to reset user progress to day 1
CREATE OR REPLACE FUNCTION reset_to_day_1(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_result JSON;
  v_subject_id UUID;
BEGIN
  -- Get user's active subject
  SELECT rs.id INTO v_subject_id
  FROM public.reading_subjects rs
  JOIN public.users u ON u.preference_id = rs.preference_id
  WHERE u.id = p_user_id AND rs.is_active = true
  ORDER BY rs.created_at
  LIMIT 1;
  
  IF v_subject_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'No active subject found for user'
    );
  END IF;
  
  -- Reset user progress to day 1
  INSERT INTO public.user_reading_progress (user_id, subject_id, current_day, last_read_date)
  VALUES (p_user_id, v_subject_id, 1, CURRENT_DATE)
  ON CONFLICT (user_id, subject_id) DO UPDATE SET
    current_day = 1,
    last_read_date = CURRENT_DATE;
  
  SELECT json_build_object(
    'success', true,
    'message', 'Progress reset to day 1 successfully',
    'current_day', 1
  ) INTO v_result;
  
  RETURN v_result;
END;
$$;

-- RPC function to get current day and max day info
CREATE OR REPLACE FUNCTION get_reading_info(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_result JSON;
  v_subject_id UUID;
  v_current_day INTEGER;
  v_max_day INTEGER;
  v_subject_name VARCHAR;
BEGIN
  -- Get user's active subject
  SELECT rs.id, rs.name INTO v_subject_id, v_subject_name
  FROM public.reading_subjects rs
  JOIN public.users u ON u.preference_id = rs.preference_id
  WHERE u.id = p_user_id AND rs.is_active = true
  ORDER BY rs.created_at
  LIMIT 1;
  
  IF v_subject_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'No active subject found for user'
    );
  END IF;
  
  -- Get current day from progress
  SELECT COALESCE(current_day, 1) INTO v_current_day
  FROM public.user_reading_progress
  WHERE user_id = p_user_id AND subject_id = v_subject_id;
  
  IF v_current_day IS NULL THEN
    v_current_day := 1;
  END IF;
  
  -- Get max available day
  SELECT MAX(day_sequence) INTO v_max_day
  FROM public.daily_readings
  WHERE subject_id = v_subject_id;
  
  SELECT json_build_object(
    'success', true,
    'subject_name', v_subject_name,
    'current_day', v_current_day,
    'max_day', COALESCE(v_max_day, 1),
    'has_next_day', v_current_day < COALESCE(v_max_day, 1)
  ) INTO v_result;
  
  RETURN v_result;
END;
$$;
