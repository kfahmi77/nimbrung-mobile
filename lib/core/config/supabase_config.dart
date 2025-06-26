import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'https://supabase-nimbrung.vpsfahmi.my.id';
  static const String supabaseAnonKey =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc1MDYxOTM0MCwiZXhwIjo0OTA2MjkyOTQwLCJyb2xlIjoiYW5vbiJ9.5aCXxvN3eNX37RQpBa5r_F-FIpiyYmLi7e4H5GVaglM';

  static SupabaseClient get instance => Supabase.instance.client;

  // Table names
  static const String usersTable = 'users';
  static const String preferencesTable = 'preferences';
  static const String authProviderTable = 'auth_provider';
}

// Extension untuk handling errors
extension SupabaseErrorExtension on PostgrestException {
  String get userFriendlyMessage {
    switch (code) {
      case '23505': // unique_violation
        if (details?.toString().contains('email') == true) {
          return 'Email sudah terdaftar. Silakan gunakan email lain.';
        }
        return 'Data sudah ada. Silakan coba lagi dengan data yang berbeda.';
      case '23503': // foreign_key_violation
        return 'Data referensi tidak valid.';
      case '23514': // check_violation
        return 'Data tidak memenuhi kriteria yang diperlukan.';
      default:
        return 'Terjadi kesalahan pada server.';
    }
  }
}
