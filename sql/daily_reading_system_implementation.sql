-- DAILY READING SYSTEM IMPLEMENTATION
-- Based on the documentation with weight-based scope system
-- This implements the complete daily reading system as specified

-- ============================================================================
-- STEP 1: Create Base Tables According to Documentation
-- ============================================================================

-- 1. User Preferences Table
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reading_id UUID NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
    reading_date DATE NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, reading_date)
);

-- 5. Reading Feedbacks Table (Feedback Bacaan)
CREATE TABLE IF NOT EXISTS reading_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
    AND up.is_active = true
    ORDER BY s.weight DESC, s.name;
END;
$$;

-- Function to update scope weight
CREATE OR REPLACE FUNCTION update_scope_weight(
    p_user_id UUID,
    p_scope_id UUID,
    p_weight INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Validate weight
    IF p_weight < 0 OR p_weight > 5 THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Weight must be between 0 and 5'
        );
    END IF;

    -- Update scope weight (only if user owns this scope through their preference)
    UPDATE scopes 
    SET weight = p_weight, updated_at = NOW()
    WHERE id = p_scope_id
    AND preference_id IN (
        SELECT id FROM user_preferences 
        WHERE user_id = p_user_id AND is_active = true
    );

    IF FOUND THEN
        v_result := json_build_object(
            'success', true,
            'message', 'Scope weight updated successfully'
        );
    ELSE
        v_result := json_build_object(
            'success', false,
            'message', 'Scope not found or access denied'
        );
    END IF;

    RETURN v_result;
END;
$$;

-- Function to get reading history
CREATE OR REPLACE FUNCTION get_reading_history(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 30
)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    scope_name VARCHAR,
    reading_date DATE,
    is_read BOOLEAN,
    feedback_type VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dr.id,
        r.title,
        COALESCE(s.name, 'General') as scope_name,
        dr.reading_date,
        dr.is_read,
        rf.feedback_type
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    LEFT JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id
    ORDER BY dr.reading_date DESC
    LIMIT p_limit;
END;
$$;

-- ============================================================================
-- STEP 4: Create Row Level Security (RLS) Policies
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE scopes ENABLE ROW LEVEL SECURITY;
ALTER TABLE readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_feedbacks ENABLE ROW LEVEL SECURITY;

-- User Preferences Policies
CREATE POLICY "Users can view their own preferences" ON user_preferences
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own preferences" ON user_preferences
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own preferences" ON user_preferences
    FOR UPDATE USING (auth.uid() = user_id);

-- Scopes Policies (users can access scopes of their preferences)
CREATE POLICY "Users can view scopes of their preferences" ON scopes
    FOR SELECT USING (
        preference_id IN (
            SELECT id FROM user_preferences 
            WHERE user_id = auth.uid()
        )
    );

-- Readings Policies (all users can read all readings)
CREATE POLICY "All users can view active readings" ON readings
    FOR SELECT USING (is_active = true);

-- Daily Readings Policies
CREATE POLICY "Users can view their own daily readings" ON daily_readings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own daily readings" ON daily_readings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own daily readings" ON daily_readings
    FOR UPDATE USING (auth.uid() = user_id);

-- Reading Feedbacks Policies
CREATE POLICY "Users can view their own feedback" ON reading_feedbacks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own feedback" ON reading_feedbacks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own feedback" ON reading_feedbacks
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================================
-- STEP 5: Insert Sample Data
-- ============================================================================

-- Sample preferences
INSERT INTO user_preferences (id, user_id, name, description) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Pengembangan Diri', 'Fokus pada pertumbuhan pribadi dan profesional'),
    ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Teknologi', 'Terkini tentang teknologi dan inovasi')
ON CONFLICT (id) DO NOTHING;

-- Sample scopes for Pengembangan Diri
INSERT INTO scopes (id, name, preference_id, weight, description) VALUES
    ('550e8400-e29b-41d4-a716-446655440010', 'Motivasi', '550e8400-e29b-41d4-a716-446655440001', 5, 'Motivasi dan inspirasi harian'),
    ('550e8400-e29b-41d4-a716-446655440011', 'Produktivitas', '550e8400-e29b-41d4-a716-446655440001', 4, 'Tips dan strategi produktivitas'),
    ('550e8400-e29b-41d4-a716-446655440012', 'Kesehatan Mental', '550e8400-e29b-41d4-a716-446655440001', 2, 'Kesehatan mental dan well-being'),
    ('550e8400-e29b-41d4-a716-446655440013', 'Keuangan', '550e8400-e29b-41d4-a716-446655440001', 1, 'Literasi keuangan dan investasi'),
    ('550e8400-e29b-41d4-a716-446655440014', 'Hubungan', '550e8400-e29b-41d4-a716-446655440001', 0, 'Hubungan interpersonal')
ON CONFLICT (id) DO NOTHING;

-- Sample readings
INSERT INTO readings (id, title, content, quote, scope_id) VALUES
    ('550e8400-e29b-41d4-a716-446655440020', 'Kekuatan Mindset Positif', 'Mindset positif adalah salah satu kunci utama dalam mencapai kesuksesan. Ketika kita memiliki cara berpikir yang positif, kita akan lebih mudah melihat peluang di setiap tantangan yang dihadapi...', 'Pikiran positif menghasilkan tindakan positif', '550e8400-e29b-41d4-a716-446655440010'),
    ('550e8400-e29b-41d4-a716-446655440021', 'Teknik Pomodoro untuk Produktivitas', 'Teknik Pomodoro adalah metode manajemen waktu yang dikembangkan oleh Francesco Cirillo. Teknik ini menggunakan timer untuk membagi pekerjaan menjadi interval-interval...', 'Fokus adalah kunci produktivitas', '550e8400-e29b-41d4-a716-446655440011'),
    ('550e8400-e29b-41d4-a716-446655440022', 'Mengelola Stress dengan Mindfulness', 'Mindfulness adalah praktik meditasi yang membantu kita untuk lebih sadar akan momen saat ini. Dengan berlatih mindfulness, kita dapat mengurangi stress dan anxiety...', 'Hidup di masa sekarang adalah hadiah terbesar', '550e8400-e29b-41d4-a716-446655440012')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 6: Test the Implementation
-- ============================================================================

DO $$
DECLARE
    test_user_id UUID := '550e8400-e29b-41d4-a716-446655440000';
    reading_result RECORD;
BEGIN
    RAISE NOTICE '=== TESTING DAILY READING SYSTEM ===';
    
    -- Test getting daily reading
    RAISE NOTICE 'Getting daily reading for user...';
    FOR reading_result IN 
        SELECT * FROM get_daily_reading(test_user_id)
    LOOP
        RAISE NOTICE 'Reading: % - %', reading_result.title, reading_result.scope_name;
    END LOOP;
    
    -- Test user preferences
    RAISE NOTICE 'Getting user preferences...';
    FOR reading_result IN 
        SELECT * FROM get_user_preferences(test_user_id)
    LOOP
        RAISE NOTICE 'Scope: % (Weight: %)', reading_result.scope_name, reading_result.scope_weight;
    END LOOP;
    
    RAISE NOTICE '=== TEST COMPLETED ===';
END;
$$;
