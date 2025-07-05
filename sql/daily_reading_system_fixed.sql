-- DAILY READING SYSTEM IMPLEMENTATION (UPDATED FOR EXISTING SCHEMA)
-- Updated to work with existing database schema
-- This matches the actual database structure provided

-- ============================================================================
-- STEP 1: Create RPC Functions for Daily Reading System (Existing Schema)
-- ============================================================================

-- Function to generate daily reading based on user preferences and scope weights
CREATE OR REPLACE FUNCTION generate_daily_reading(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    selected_reading_id UUID;
BEGIN
    -- Check if user already has a reading for today
    IF EXISTS (
        SELECT 1 FROM daily_readings 
        WHERE user_id = p_user_id 
        AND reading_date = CURRENT_DATE
    ) THEN
        RETURN; -- Already has reading for today
    END IF;

    -- Generate new daily reading using weighted random selection
    WITH user_preference AS (
        SELECT u.preference_id
        FROM users u
        WHERE u.id = p_user_id
        AND u.preference_id IS NOT NULL
        LIMIT 1
    ),
    user_scopes AS (
        SELECT s.id as scope_id, s.name as scope_name, s.weight
        FROM scopes s
        JOIN user_preference up ON s.preference_id = up.preference_id
        WHERE s.weight > 0  -- Only include scopes with weight > 0
    ),
    weighted_readings AS (
        SELECT r.id, 
               COALESCE(us.weight, 1) as weight
        FROM readings r
        LEFT JOIN user_scopes us ON r.scope_id = us.scope_id
        WHERE r.is_active = true
        AND r.id NOT IN (
            -- Exclude recently read articles (last 30 days)
            SELECT reading_id 
            FROM daily_readings 
            WHERE user_id = p_user_id 
            AND reading_date > CURRENT_DATE - INTERVAL '30 days'
        )
        AND (r.scope_id IS NULL OR us.scope_id IS NOT NULL) -- Only include readings with valid scopes or general readings
    ),
    selected_reading AS (
        SELECT wr.id
        FROM weighted_readings wr
        ORDER BY RANDOM() * POWER(wr.weight, 2) DESC -- Square the weight for more pronounced effect
        LIMIT 1
    )
    SELECT id INTO selected_reading_id FROM selected_reading;

    -- Insert the selected reading into daily_readings table if we found one
    IF selected_reading_id IS NOT NULL THEN
        INSERT INTO daily_readings (user_id, reading_id, reading_date)
        VALUES (p_user_id, selected_reading_id, CURRENT_DATE);
    END IF;
END;
$$;

-- Function to get daily reading for a user
CREATE OR REPLACE FUNCTION get_daily_reading(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title TEXT,
    content TEXT,
    quote TEXT,
    scope_name TEXT,
    reading_date DATE,
    is_read BOOLEAN,
    user_feedback TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- First try to get existing daily reading for today
    RETURN QUERY
    SELECT 
        dr.id,
        r.title::TEXT,
        r.content,
        r.quote,
        COALESCE(s.name::TEXT, 'General'::TEXT) as scope_name,
        dr.reading_date,
        dr.is_read,
        rf.feedback_type::TEXT as user_feedback
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    LEFT JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id
    AND dr.reading_date = CURRENT_DATE;

    -- If no reading exists for today, generate one
    IF NOT FOUND THEN
        -- First generate the reading by calling the generation function
        PERFORM generate_daily_reading(p_user_id);
        
        -- Then return the generated reading
        RETURN QUERY
        SELECT 
            dr.id,
            r.title::TEXT,
            r.content,
            r.quote,
            COALESCE(s.name::TEXT, 'General'::TEXT) as scope_name,
            dr.reading_date,
            dr.is_read,
            rf.feedback_type::TEXT as user_feedback
        FROM daily_readings dr
        JOIN readings r ON dr.reading_id = r.id
        LEFT JOIN scopes s ON r.scope_id = s.id
        LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
        WHERE dr.user_id = p_user_id
        AND dr.reading_date = CURRENT_DATE;
    END IF;
END;
$$;

-- Function to mark reading as read
CREATE OR REPLACE FUNCTION mark_reading_as_read(p_user_id UUID, p_reading_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Update daily_readings to mark as read
    UPDATE daily_readings 
    SET is_read = true
    WHERE user_id = p_user_id 
    AND reading_id = p_reading_id
    AND reading_date = CURRENT_DATE;

    -- Check if update was successful
    IF FOUND THEN
        v_result := json_build_object(
            'success', true,
            'message', 'Reading marked as read'
        );
    ELSE
        v_result := json_build_object(
            'success', false,
            'message', 'Reading not found or already marked as read'
        );
    END IF;

    RETURN v_result;
END;
$$;

-- Function to submit reading feedback
CREATE OR REPLACE FUNCTION submit_reading_feedback(
    p_user_id UUID,
    p_reading_id UUID,
    p_feedback_type VARCHAR
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Validate feedback type
    IF p_feedback_type NOT IN ('up', 'down') THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Invalid feedback type. Must be "up" or "down"'
        );
    END IF;

    -- Insert or update feedback
    INSERT INTO reading_feedbacks (user_id, reading_id, feedback_type)
    VALUES (p_user_id, p_reading_id, p_feedback_type)
    ON CONFLICT (user_id, reading_id) 
    DO UPDATE SET 
        feedback_type = EXCLUDED.feedback_type,
        updated_at = NOW();

    v_result := json_build_object(
        'success', true,
        'message', 'Feedback submitted successfully',
        'feedback_type', p_feedback_type
    );

    RETURN v_result;
END;
$$;

-- Function to get user preferences and scopes (updated for existing schema)
CREATE OR REPLACE FUNCTION get_user_preferences(p_user_id UUID)
RETURNS TABLE (
    preference_id UUID,
    preference_name TEXT,
    scope_id UUID,
    scope_name TEXT,
    scope_weight INTEGER,
    scope_description TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as preference_id,
        p.preferences_name::TEXT as preference_name,
        s.id as scope_id,
        s.name::TEXT as scope_name,
        s.weight as scope_weight,
        s.description as scope_description
    FROM users u
    LEFT JOIN preferences p ON u.preference_id = p.id
    LEFT JOIN scopes s ON s.preference_id = p.id
    WHERE u.id = p_user_id
    AND u.preference_id IS NOT NULL;
END;
$$;

-- ============================================================================
-- STEP 2: Create Indexes for Performance (if not exists)
-- ============================================================================

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_daily_readings_user_date ON daily_readings(user_id, reading_date);
CREATE INDEX IF NOT EXISTS idx_daily_readings_date ON daily_readings(reading_date);
CREATE INDEX IF NOT EXISTS idx_reading_feedbacks_user_reading ON reading_feedbacks(user_id, reading_id);
CREATE INDEX IF NOT EXISTS idx_scopes_preference_id ON scopes(preference_id);
CREATE INDEX IF NOT EXISTS idx_scopes_weight ON scopes(weight);
CREATE INDEX IF NOT EXISTS idx_readings_scope_id ON readings(scope_id);
CREATE INDEX IF NOT EXISTS idx_readings_is_active ON readings(is_active);
CREATE INDEX IF NOT EXISTS idx_users_preference_id ON users(preference_id);

-- Add unique constraint for daily_readings if not exists
DO $$
BEGIN
    BEGIN
        ALTER TABLE daily_readings ADD CONSTRAINT daily_readings_user_date_unique UNIQUE (user_id, reading_date);
    EXCEPTION
        WHEN duplicate_table THEN NULL;
    END;
END $$;

-- Add unique constraint for reading_feedbacks if not exists
DO $$
BEGIN
    BEGIN
        ALTER TABLE reading_feedbacks ADD CONSTRAINT reading_feedbacks_user_reading_unique UNIQUE (user_id, reading_id);
    EXCEPTION
        WHEN duplicate_table THEN NULL;
    END;
END $$;

-- ============================================================================
-- STEP 3: Sample Data for Testing (Optional)
-- ============================================================================

-- Sample preferences (insert if not exists)
INSERT INTO preferences (id, preferences_name) 
SELECT gen_random_uuid(), 'Psikologi'
WHERE NOT EXISTS (SELECT 1 FROM preferences WHERE preferences_name = 'Psikologi');

-- Sample scopes (using existing preference)
INSERT INTO scopes (name, preference_id, weight, description) 
SELECT 'Psikologi Kognitif', p.id, 5, 'Mempelajari proses mental internal'
FROM preferences p 
WHERE p.preferences_name = 'Psikologi'
AND NOT EXISTS (SELECT 1 FROM scopes WHERE name = 'Psikologi Kognitif');

INSERT INTO scopes (name, preference_id, weight, description) 
SELECT 'Psikologi Sosial', p.id, 3, 'Mempelajari interaksi sosial'
FROM preferences p 
WHERE p.preferences_name = 'Psikologi'
AND NOT EXISTS (SELECT 1 FROM scopes WHERE name = 'Psikologi Sosial');

INSERT INTO scopes (name, preference_id, weight, description) 
SELECT 'Psikologi Perkembangan', p.id, 4, 'Mempelajari perkembangan manusia'
FROM preferences p 
WHERE p.preferences_name = 'Psikologi'
AND NOT EXISTS (SELECT 1 FROM scopes WHERE name = 'Psikologi Perkembangan');

-- Sample readings
INSERT INTO readings (title, content, quote, scope_id) 
SELECT 
    'Psikologi Kognitif: Memahami Proses Mental',
    'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran, dan pengambilan keputusan. Bidang ini mengkaji bagaimana manusia memproses informasi, mengorganisir pengetahuan, dan membuat keputusan dalam kehidupan sehari-hari.',
    'Pikiran manusia adalah komputer biologis yang paling canggih.',
    s.id
FROM scopes s 
WHERE s.name = 'Psikologi Kognitif'
AND NOT EXISTS (SELECT 1 FROM readings WHERE title = 'Psikologi Kognitif: Memahami Proses Mental')
LIMIT 1;

INSERT INTO readings (title, content, quote, scope_id) 
SELECT 
    'Psikologi Sosial: Pengaruh Lingkungan Terhadap Perilaku',
    'Psikologi sosial mempelajari bagaimana pikiran, perasaan, dan perilaku individu dipengaruhi oleh kehadiran aktual, yang dibayangkan, atau tersirat dari orang lain. Bidang ini mengeksplorasi fenomena seperti konformitas, obediensi, dan dinamika kelompok.',
    'Manusia adalah makhluk sosial yang tidak dapat hidup terpisah dari lingkungannya.',
    s.id
FROM scopes s 
WHERE s.name = 'Psikologi Sosial'
AND NOT EXISTS (SELECT 1 FROM readings WHERE title = 'Psikologi Sosial: Pengaruh Lingkungan Terhadap Perilaku')
LIMIT 1;
