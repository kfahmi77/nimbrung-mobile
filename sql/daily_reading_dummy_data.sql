-- Dummy Data for Daily Reading Feature

-- Insert preferences if not exists
INSERT INTO preferences (id, preferences_name) VALUES
  ('pref-programming-001', 'Programming'),
  ('pref-psychology-002', 'Psikologi'),
  ('pref-business-003', 'Bisnis'),
  ('pref-design-004', 'Desain')
ON CONFLICT (id) DO NOTHING;

-- Insert sample users if not exists
INSERT INTO users (id, email, preference_id, username, fullname) VALUES
  ('user-prog-001', 'programmer@example.com', 'pref-programming-001', 'programmer', 'John Developer'),
  ('user-psych-002', 'psychologist@example.com', 'pref-psychology-002', 'psychologist', 'Sarah Chen'),
  ('user-business-003', 'business@example.com', 'pref-business-003', 'business', 'Mike Entrepreneur'),
  ('user-design-004', 'designer@example.com', 'pref-design-004', 'designer', 'Anna Creative')
ON CONFLICT (id) DO NOTHING;

-- Insert reading subjects
INSERT INTO reading_subjects (name, description, icon_name, color_hex, preference_id) VALUES
  ('Learn Flutter', 'Flutter untuk pemula - Pelajari framework terpopuler untuk mobile development', 'flutter', '#42A5F5', 'pref-programming-001'),
  ('Mastering React', 'React JS fundamental sampai advanced untuk web development modern', 'react', '#61DAFB', 'pref-programming-001'),
  ('Psikologi Kognitif', 'Memahami cara kerja pikiran manusia dan proses mental', 'psychology', '#9C27B0', 'pref-psychology-002'),
  ('Psikologi Sosial', 'Bagaimana manusia berinteraksi dalam konteks sosial', 'social', '#E91E63', 'pref-psychology-002'),
  ('Startup Fundamental', 'Dasar-dasar membangun startup dari nol hingga sukses', 'startup', '#FF9800', 'pref-business-003'),
  ('Digital Marketing', 'Strategi pemasaran digital yang efektif di era modern', 'marketing', '#4CAF50', 'pref-business-003'),
  ('UI/UX Design', 'Prinsip-prinsip desain antarmuka yang user-friendly', 'design', '#F44336', 'pref-design-004'),
  ('Graphic Design', 'Fundamental desain grafis untuk komunikasi visual', 'graphic', '#673AB7', 'pref-design-004');

-- Insert daily readings for Flutter
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter'),
    1,
    'Pengenalan Flutter',
    'Flutter adalah framework open-source dari Google untuk membuat aplikasi mobile, web, dan desktop dengan satu codebase. Flutter menggunakan bahasa pemrograman Dart dan memungkinkan developer untuk membuat aplikasi yang fast, beautiful, dan native-compiled.

Key Features Flutter:
1. Single Codebase: Tulis sekali, jalankan di mana saja
2. Hot Reload: Perubahan kode langsung terlihat dalam detik
3. Native Performance: Performa mendekati aplikasi native
4. Rich UI Widgets: Thousands of customizable widgets
5. Growing Community: Dukungan komunitas yang besar

Flutter telah digunakan oleh perusahaan besar seperti Google, Alibaba, BMW, dan banyak lagi. Dengan Flutter, Anda dapat mengembangkan aplikasi untuk iOS, Android, web, Windows, macOS, dan Linux.',
    'Flutter memungkinkan pengembangan aplikasi cross-platform dengan satu codebase, menghemat waktu dan biaya development.',
    'Besok kita akan mempelajari konsep Widget - building block fundamental dari aplikasi Flutter'
  ),
  (
    (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter'),
    2,
    'Widget: Building Blocks Flutter',
    'Di Flutter, semuanya adalah Widget! Widget adalah building block fundamental untuk membuat user interface. Terdapat dua jenis widget utama:

1. StatelessWidget
- Widget yang tidak berubah setelah dibuat
- Cocok untuk UI yang statis
- Contoh: Text, Icon, Image

2. StatefulWidget  
- Widget yang dapat berubah state-nya
- Cocok untuk UI yang interaktif
- Contoh: Button, Form, Animation

Widget Tree:
Flutter mengorganisir widget dalam bentuk tree structure. Parent widget mengandung child widget, dan setiap widget dapat memiliki properties yang mengontrol appearance dan behavior.

Contoh Widget Sederhana:
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Hello Flutter")),
        body: Center(child: Text("Welcome to Flutter!")),
      ),
    );
  }
}
```

Widget Composition adalah kunci untuk membuat UI yang complex dengan menggabungkan widget-widget sederhana.',
    'Widget adalah building block fundamental Flutter. Ada StatelessWidget untuk UI statis dan StatefulWidget untuk UI interaktif.',
    'Besok kita akan belajar tentang Layout Widgets untuk mengatur posisi dan ukuran widget'
  ),
  (
    (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter'),
    3,
    'Layout Widgets dalam Flutter',
    'Layout widgets mengatur bagaimana child widgets diposisikan dan berukuran di layar. Flutter menyediakan berbagai layout widgets untuk kebutuhan yang berbeda:

Single Child Layout Widgets:
1. Container - Widget serbaguna dengan padding, margin, decoration
2. Center - Menempatkan child di tengah
3. Align - Mengatur alignment child dengan presisi
4. Padding - Memberikan space di sekitar child
5. SizedBox - Memberikan ukuran tetap

Multi Child Layout Widgets:
1. Row - Menyusun children secara horizontal
2. Column - Menyusun children secara vertikal  
3. Stack - Menumpuk children satu di atas yang lain
4. Wrap - Menyusun children dengan automatic wrapping
5. ListView - Scrollable list dari children

Flex Properties:
- MainAxis: arah utama layout (horizontal untuk Row, vertical untuk Column)
- CrossAxis: arah tegak lurus main axis
- MainAxisAlignment: mengatur alignment di main axis
- CrossAxisAlignment: mengatur alignment di cross axis

Contoh Layout:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Item 1"),
    Text("Item 2"),
    Row(
      children: [
        Icon(Icons.star),
        Text("Rating"),
      ],
    ),
  ],
)
```',
    'Layout widgets mengatur posisi dan ukuran child widgets. Row untuk horizontal, Column untuk vertical, Stack untuk overlay.',
    'Besok kita akan mempelajari State Management untuk mengelola data aplikasi'
  );

-- Insert daily readings for Psikologi Kognitif
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    (SELECT id FROM reading_subjects WHERE name = 'Psikologi Kognitif'),
    1,
    'Pengantar Psikologi Kognitif',
    'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran, dan pengambilan keputusan. Bidang ini berkembang pesat sejak "revolusi kognitif" pada tahun 1950-an.

Fokus Utama Psikologi Kognitif:
1. Persepsi - Bagaimana kita menginterpretasi informasi sensorik
2. Memori - Proses encoding, storage, dan retrieval informasi
3. Perhatian - Bagaimana kita fokus pada stimulus tertentu
4. Bahasa - Pemahaman dan produksi bahasa
5. Problem Solving - Cara menyelesaikan masalah
6. Decision Making - Proses pengambilan keputusan

Metode Penelitian:
- Eksperimen laboratorium terkontrol
- Neuroimaging (fMRI, EEG)
- Computational modeling
- Case studies dari pasien dengan brain damage

Psikologi kognitif memiliki aplikasi luas dalam pendidikan, terapi, desain teknologi, dan pengembangan AI. Pemahaman tentang bagaimana manusia memproses informasi membantu kita merancang sistem yang lebih user-friendly.',
    'Psikologi kognitif mempelajari proses mental internal seperti persepsi, memori, dan pemikiran untuk memahami bagaimana manusia memproses informasi.',
    'Besok kita akan mendalami sistem memori manusia dan bagaimana informasi disimpan dan diambil'
  ),
  (
    (SELECT id FROM reading_subjects WHERE name = 'Psikologi Kognitif'),
    2,
    'Sistem Memori Manusia',
    'Memori adalah kemampuan untuk menyimpan dan mengambil informasi. Model multi-store dari Atkinson & Shiffrin (1968) membagi memori menjadi tiga sistem utama:

1. Sensory Memory
- Durasi: 0.5-3 detik
- Kapasitas: Sangat besar
- Fungsi: Menahan informasi sensorik sebentar
- Contoh: Iconic memory (visual), Echoic memory (auditory)

2. Short-term Memory (STM)
- Durasi: 15-30 detik tanpa rehearsal
- Kapasitas: 7±2 items (Miller''s Magic Number)
- Fungsi: Working memory untuk pemrosesan sementara
- Dapat diperpanjang dengan rehearsal

3. Long-term Memory (LTM)
- Durasi: Bisa permanen
- Kapasitas: Tidak terbatas
- Jenis: Declarative (explicit) dan Procedural (implicit)

Types of Long-term Memory:
- Episodic: Memori autobiografis (kejadian personal)
- Semantic: Memori faktual (pengetahuan umum)
- Procedural: Memori keterampilan dan habits

Proses Memori:
1. Encoding: Mengubah informasi ke format yang bisa disimpan
2. Storage: Mempertahankan informasi dalam memori
3. Retrieval: Mengakses informasi yang tersimpan

Forgetting terjadi karena decay, interference, atau retrieval failure.',
    'Memori manusia terdiri dari sensory memory, short-term memory, dan long-term memory dengan karakteristik durasi dan kapasitas yang berbeda.',
    'Besok kita akan belajar tentang perhatian dan bagaimana otak memilih informasi yang akan diproses'
  );

-- Insert daily readings for Startup Fundamental
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    (SELECT id FROM reading_subjects WHERE name = 'Startup Fundamental'),
    1,
    'Apa itu Startup?',
    'Startup adalah perusahaan muda yang dirancang untuk tumbuh dengan cepat dan menyelesaikan masalah melalui inovasi teknologi atau model bisnis. Berbeda dengan bisnis tradisional, startup memiliki karakteristik khusus:

Karakteristik Startup:
1. Scalability - Kemampuan untuk tumbuh dengan cepat
2. Innovation - Menghadirkan solusi baru atau cara baru
3. Uncertainty - Beroperasi dalam kondisi ketidakpastian tinggi
4. Resource Constraints - Biasanya dimulai dengan modal terbatas
5. Growth Mindset - Fokus pada pertumbuhan eksponensial

Jenis-jenis Startup:
1. Tech Startup - Berbasis teknologi (software, hardware)
2. Fintech - Financial technology
3. Healthtech - Teknologi kesehatan  
4. Edtech - Educational technology
5. E-commerce - Platform perdagangan online
6. Social Impact - Startup dengan misi sosial

Ecosystem Startup:
- Entrepreneurs: Founders dan tim
- Investors: Angel, VC, Corporate VC
- Accelerators & Incubators
- Government support
- Universities
- Service providers (legal, accounting, marketing)

Startup bukanlah small business. Small business fokus pada profitabilitas dan sustainability, sedangkan startup fokus pada rapid growth dan market disruption.',
    'Startup adalah perusahaan muda yang dirancang untuk tumbuh cepat melalui inovasi, berbeda dengan bisnis tradisional yang fokus pada stabilitas.',
    'Besok kita akan mempelajari konsep MVP (Minimum Viable Product) dan bagaimana memvalidasi ide bisnis'
  );

-- Insert daily readings for UI/UX Design
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    (SELECT id FROM reading_subjects WHERE name = 'UI/UX Design'),
    1,
    'Perbedaan UI dan UX Design',
    'UI (User Interface) dan UX (User Experience) sering disalahpahami sebagai hal yang sama, padahal keduanya memiliki fokus yang berbeda meskipun saling terkait erat.

UX Design (User Experience):
- Fokus pada overall experience pengguna
- Research, wireframing, prototyping, testing
- Memahami user needs, pain points, dan goals
- Information architecture dan user flows
- Usability dan accessibility
- "How it works"

UI Design (User Interface):
- Fokus pada visual interface dan interaksi
- Typography, color schemes, icons, images
- Layout, spacing, dan visual hierarchy
- Interactive elements (buttons, forms, navigation)
- Brand consistency dan visual identity
- "How it looks"

Design Process:
1. Research - Memahami users dan market
2. Define - Mendefinisikan problems dan requirements
3. Ideate - Brainstorming solutions
4. Design - Membuat wireframes dan mockups
5. Test - User testing dan iteration
6. Implement - Collaboration dengan developers

Key Principles:
- User-centered design
- Consistency
- Simplicity
- Accessibility
- Feedback dan error handling
- Mobile-first approach

Good UX tanpa good UI akan susah digunakan. Good UI tanpa good UX akan cantik tapi tidak berguna.',
    'UI fokus pada tampilan visual interface, sedangkan UX fokus pada keseluruhan pengalaman pengguna. Keduanya harus bekerja sama untuk menciptakan produk yang sukses.',
    'Besok kita akan mempelajari prinsip-prinsip fundamental dalam desain interface yang user-friendly'
  );

-- Insert some user progress
INSERT INTO user_reading_progress (user_id, subject_id, current_day, total_completed, streak_days, started_date, last_read_date) VALUES
  (
    'user-prog-001', 
    (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter'),
    2, 1, 1, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE - INTERVAL '1 day'
  ),
  (
    'user-psych-002',
    (SELECT id FROM reading_subjects WHERE name = 'Psikologi Kognitif'),
    1, 0, 0, CURRENT_DATE, NULL
  );

-- Insert some reading completions
INSERT INTO reading_completions (user_id, reading_id, actual_read_time_seconds, was_helpful) VALUES
  (
    'user-prog-001',
    (SELECT dr.id FROM daily_readings dr 
     JOIN reading_subjects rs ON dr.subject_id = rs.id 
     WHERE rs.name = 'Learn Flutter' AND dr.day_sequence = 1),
    280, true
  );
