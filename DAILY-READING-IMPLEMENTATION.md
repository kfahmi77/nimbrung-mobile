Fitur Bacaan Harian - Dokumentasi Teknis (Preferensi Tunggal)
🗂️ Struktur Tabel SQL

1. reading_subjects
   sql
   Salin
   Edit
   CREATE TABLE reading_subjects (
   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   description TEXT,
   icon_name VARCHAR(50),
   color_hex VARCHAR(7),
   total_days INTEGER DEFAULT 365,
   is_active BOOLEAN DEFAULT true,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
   preference_id UUID REFERENCES preferences(id)
   );
2. daily_readings
   sql
   Salin
   Edit
   CREATE TABLE daily_readings (
   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
   subject_id UUID REFERENCES reading_subjects(id),
   day_sequence INTEGER NOT NULL,
   title VARCHAR(255) NOT NULL,
   content TEXT NOT NULL,
   key_insight TEXT,
   tomorrow_hint TEXT,
   read_time_minutes INTEGER DEFAULT 5,
   internal_difficulty INTEGER DEFAULT 1,
   internal_level VARCHAR(20),
   prerequisites_met BOOLEAN DEFAULT true,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
   UNIQUE(subject_id, day_sequence)
   );

CREATE INDEX idx_daily_readings_subject_day ON daily_readings(subject_id, day_sequence); 3. user_reading_progress
sql
Salin
Edit
CREATE TABLE user_reading_progress (
id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
user_id UUID REFERENCES auth.users(id),
subject_id UUID REFERENCES reading_subjects(id),
current_day INTEGER DEFAULT 1,
total_completed INTEGER DEFAULT 0,
streak_days INTEGER DEFAULT 0,
started_date DATE DEFAULT CURRENT_DATE,
last_read_date DATE,
milestone_30 BOOLEAN DEFAULT false,
milestone_100 BOOLEAN DEFAULT false,
milestone_365 BOOLEAN DEFAULT false,
UNIQUE(user_id, subject_id)
); 4. reading_completions
sql
Salin
Edit
CREATE TABLE reading_completions (
id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
user_id UUID REFERENCES auth.users(id),
reading_id UUID REFERENCES daily_readings(id),
completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
actual_read_time_seconds INTEGER,
was_helpful BOOLEAN,
user_note TEXT,
UNIQUE(user_id, reading_id)
);
🧪 Dummy Data SQL
preferences
sql
Salin
Edit
INSERT INTO preferences (id, preferences_name) VALUES
('pref-id-1', 'Programming');
users
sql
Salin
Edit
INSERT INTO users (id, email, preference_id)
VALUES ('user-uuid-1', 'user@example.com', 'pref-id-1');
reading_subjects
sql
Salin
Edit
INSERT INTO reading_subjects (name, description, icon_name, color_hex, preference_id)
VALUES ('Learn Flutter', 'Flutter for beginners', 'flutter', '#42A5F5', 'pref-id-1');
daily_readings
sql
Salin
Edit
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint)
VALUES (
(SELECT id FROM reading_subjects WHERE name = 'Learn Flutter'),
1,
'Pengenalan Flutter',
'Flutter adalah framework open-source dari Google...',
'Flutter memudahkan pembuatan aplikasi cross-platform',
'Besok kita akan bahas Widget'
);
💻 Implementasi Flutter + Supabase

1. Ambil Bacaan Harian Pertama User
   dart
   Salin
   Edit
   final userId = supabase.auth.currentUser?.id;
   final response = await supabase.rpc('get_today_reading', params: {
   'user_id': userId,
   'day': 1,
   });
2. Struktur Data Model
   dart
   Salin
   Edit
   class DailyReading {
   final String id;
   final String title;
   final String content;
   final String keyInsight;
   final String tomorrowHint;

DailyReading({...}); // fromJson constructor
} 3. Menyimpan Progres Bacaan
dart
Salin
Edit
await supabase.from('reading_completions').insert({
'user_id': userId,
'reading_id': readingId,
'actual_read_time_seconds': 320,
'was_helpful': true,
});

await supabase.from('user_reading_progress')
.update({
'current_day': nextDay,
'total_completed': totalCompleted + 1,
'last_read_date': DateTime.now().toIso8601String(),
})
.eq('user_id', userId)
.eq('subject_id', subjectId); 4. Tampilkan Daftar Topik
dart
Salin
Edit
final subjects = await supabase
.from('reading_subjects')
.select('\*')
.eq('is_active', true); 5. Filtering Berdasarkan Preferensi User (Tunggal)
dart
Salin
Edit
final user = await supabase
.from('users')
.select('preference_id')
.eq('id', userId)
.single();

final subjects = await supabase
.from('reading_subjects')
.select('\*')
.eq('preference_id', user['preference_id']);
📌 Catatan Tambahan
Gunakan Supabase Row Level Security (RLS) untuk membatasi akses berdasarkan user_id

Buat fungsi RPC jika perlu logika lebih kompleks

Gunakan cached_network_image dan rich_text untuk render konten bacaan di UI

🧠 Pengembangan Lanjutan
Gamifikasi: badge, leaderboard

Rekomendasi berdasarkan preferensi & progres

AI summary untuk key_insight
