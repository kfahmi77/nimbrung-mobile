-- DAILY READING SYSTEM IMPLEMENTATION (UPDATED)
-- Updated to reference public.users table instead of auth.users
-- This implements the complete daily reading system as specified

-- ============================================================================
-- STEP 1: Create Base Tables According to Documentation
-- ============================================================================

-- 1. User Preferences Table
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id) -- Each user can have only one active preference
);

-- 2. Scopes Table (Ruang Lingkup)
CREATE TABLE IF NOT EXISTS scopes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    preference_id UUID NOT NULL REFERENCES user_preferences(id) ON DELETE CASCADE,
    weight INTEGER DEFAULT 1 CHECK (weight >= 0 AND weight <= 5),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Readings Table (Bacaan)
CREATE TABLE IF NOT EXISTS readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    quote TEXT,
    scope_id UUID REFERENCES scopes(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Daily Readings Table (Bacaan Harian)
CREATE TABLE IF NOT EXISTS daily_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reading_id UUID NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
    reading_date DATE NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, reading_date)
);

-- 5. Reading Feedbacks Table (Feedback Bacaan)
CREATE TABLE IF NOT EXISTS reading_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reading_id UUID NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
    feedback_type VARCHAR(10) NOT NULL CHECK (feedback_type IN ('up', 'down')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, reading_id)
);

-- ============================================================================
-- STEP 2: Create Indexes for Performance
-- ============================================================================

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_scopes_preference_id ON scopes(preference_id);
CREATE INDEX IF NOT EXISTS idx_scopes_weight ON scopes(weight);
CREATE INDEX IF NOT EXISTS idx_readings_scope_id ON readings(scope_id);
CREATE INDEX IF NOT EXISTS idx_readings_is_active ON readings(is_active);
CREATE INDEX IF NOT EXISTS idx_daily_readings_user_date ON daily_readings(user_id, reading_date);
CREATE INDEX IF NOT EXISTS idx_daily_readings_date ON daily_readings(reading_date);
CREATE INDEX IF NOT EXISTS idx_reading_feedbacks_user_reading ON reading_feedbacks(user_id, reading_id);

-- ============================================================================
-- STEP 3: Create RPC Functions for Daily Reading System
-- ============================================================================

-- Function to generate daily reading based on user preferences and scope weights
CREATE OR REPLACE FUNCTION generate_daily_reading(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    content TEXT,
    quote TEXT,
    scope_name VARCHAR,
    reading_date DATE
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Check if user already has a reading for today
    IF EXISTS (
        SELECT 1 FROM daily_readings 
        WHERE user_id = p_user_id 
        AND reading_date = CURRENT_DATE
    ) THEN
        -- Return existing reading
        RETURN QUERY
        SELECT 
            dr.id,
            r.title,
            r.content,
            r.quote,
            COALESCE(s.name, 'General') as scope_name,
            dr.reading_date
        FROM daily_readings dr
        JOIN readings r ON dr.reading_id = r.id
        LEFT JOIN scopes s ON r.scope_id = s.id
        WHERE dr.user_id = p_user_id
        AND dr.reading_date = CURRENT_DATE;
        RETURN;
    END IF;

    -- Generate new daily reading using weighted random selection
    RETURN QUERY
    WITH user_prefs AS (
        SELECT up.id as preference_id
        FROM user_preferences up
        WHERE up.user_id = p_user_id
        AND up.is_active = true
        LIMIT 1
    ),
    user_scopes AS (
        SELECT s.id as scope_id, s.name as scope_name, s.weight
        FROM scopes s
        JOIN user_prefs up ON s.preference_id = up.preference_id
        WHERE s.weight > 0  -- Only include scopes with weight > 0
    ),
    weighted_readings AS (
        SELECT r.*, 
               COALESCE(us.weight, 1) as weight,
               us.scope_name
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
        SELECT wr.id, wr.title, wr.content, wr.quote, wr.scope_name
        FROM weighted_readings wr
        ORDER BY RANDOM() * POWER(wr.weight, 2) DESC -- Square the weight for more pronounced effect
        LIMIT 1
    )
    SELECT 
        sr.id,
        sr.title,
        sr.content,
        sr.quote,
        COALESCE(sr.scope_name, 'General') as scope_name,
        CURRENT_DATE as reading_date
    FROM selected_reading sr;

    -- Insert the selected reading into daily_readings table
    INSERT INTO daily_readings (user_id, reading_id, reading_date)
    SELECT p_user_id, id, CURRENT_DATE
    FROM selected_reading;
END;
$$;

-- Function to get daily reading for a user
CREATE OR REPLACE FUNCTION get_daily_reading(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    content TEXT,
    quote TEXT,
    scope_name VARCHAR,
    reading_date DATE,
    is_read BOOLEAN,
    user_feedback VARCHAR
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
        r.title,
        r.content,
        r.quote,
        COALESCE(s.name, 'General') as scope_name,
        dr.reading_date,
        dr.is_read,
        rf.feedback_type as user_feedback
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    LEFT JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id
    AND dr.reading_date = CURRENT_DATE;

    -- If no reading exists for today, generate one
    IF NOT FOUND THEN
        -- Generate new reading and return it
        RETURN QUERY
        SELECT * FROM generate_daily_reading(p_user_id);
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

-- Function to get user preferences and scopes
CREATE OR REPLACE FUNCTION get_user_preferences(p_user_id UUID)
RETURNS TABLE (
    preference_id UUID,
    preference_name VARCHAR,
    scope_id UUID,
    scope_name VARCHAR,
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
        up.id as preference_id,
        up.name as preference_name,
        s.id as scope_id,
        s.name as scope_name,
        s.weight as scope_weight,
        s.description as scope_description
    FROM user_preferences up
    LEFT JOIN scopes s ON s.preference_id = up.id
    WHERE up.user_id = p_user_id
    AND up.is_active = true;
END;
$$;

-- ============================================================================
-- STEP 4: Sample Data for Testing (Optional)
-- ============================================================================

-- Sample preferences
INSERT INTO user_preferences (id, user_id, name, description) VALUES 
(gen_random_uuid(), gen_random_uuid(), 'Psikologi', 'Fokus pada kajian psikologi dan ilmu perilaku')
ON CONFLICT DO NOTHING;

-- Sample scopes (using a sample preference_id - should be updated with real preference_id)
INSERT INTO scopes (name, preference_id, weight, description) VALUES 
('Psikologi Kognitif', (SELECT id FROM user_preferences LIMIT 1), 5, 'Mempelajari proses mental internal'),
('Psikologi Sosial', (SELECT id FROM user_preferences LIMIT 1), 3, 'Mempelajari interaksi sosial'),
('Psikologi Perkembangan', (SELECT id FROM user_preferences LIMIT 1), 4, 'Mempelajari perkembangan manusia')
ON CONFLICT DO NOTHING;

-- Sample readings
INSERT INTO readings (title, content, quote, scope_id) VALUES 
(
    'Psikologi Kognitif: Memahami Proses Mental',
    'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran, dan pengambilan keputusan. Bidang ini mengkaji bagaimana manusia memproses informasi, mengorganisir pengetahuan, dan membuat keputusan dalam kehidupan sehari-hari.',
    'Pikiran manusia adalah komputer biologis yang paling canggih.',
    (SELECT id FROM scopes WHERE name = 'Psikologi Kognitif' LIMIT 1)
),
(
    'Psikologi Sosial: Pengaruh Lingkungan Terhadap Perilaku',
    'Psikologi sosial mempelajari bagaimana pikiran, perasaan, dan perilaku individu dipengaruhi oleh kehadiran aktual, yang dibayangkan, atau tersirat dari orang lain. Bidang ini mengeksplorasi fenomena seperti konformitas, obediensi, dan dinamika kelompok.',
    'Manusia adalah makhluk sosial yang tidak dapat hidup terpisah dari lingkungannya.',
    (SELECT id FROM scopes WHERE name = 'Psikologi Sosial' LIMIT 1)
)
ON CONFLICT DO NOTHING;
