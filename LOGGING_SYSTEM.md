# Sistem Logging untuk Registrasi dan Login

Sistem logging telah diimplementasikan untuk membantu melacak error dan debug masalah pada proses registrasi dan login menggunakan Supabase.

## Komponen yang Telah Ditambahkan Logging

### 1. AuthService (`lib/core/services/auth_service.dart`)

**Method `register()`:**
- Log info saat memulai registrasi
- Log debug untuk email yang didaftarkan
- Log debug saat membuat user dengan Supabase Auth
- Log info saat user berhasil dibuat dengan ID
- Log debug saat memasukkan data ke tabel users
- Log info saat registrasi berhasil selesai
- Log error jika gagal insert data pengguna
- Log info saat cleanup user auth setelah database insert gagal
- Log error untuk berbagai jenis exception

**Method `login()`:**
- Log info saat memulai login
- Log debug untuk email yang login
- Log warning jika login gagal
- Log info saat user berhasil ter-autentikasi
- Log info saat data user berhasil diambil
- Log error jika gagal mengambil data pengguna
- Log error untuk berbagai jenis exception

**Method lainnya:**
- `logout()`: Log info dan error
- `getCurrentUser()`: Log debug status user
- `isLoggedIn()`: Log debug status login
- `getUserProfile()`: Log debug dan error
- `updateUserProfile()`: Log info dan error
- `resetPassword()`: Log info dan error
- `getPreferences()`: Log debug dan error
- `createPreference()`: Log info dan error

### 2. AuthProvider (`lib/core/providers/auth_provider.dart`)

**RegisterNotifier:**
- Log info saat memulai proses registrasi di provider
- Log info saat registrasi berhasil
- Log warning saat registrasi gagal dengan pesan error
- Log error untuk unexpected error
- Log debug saat clearing state

**LoginNotifier:**
- Log info saat memulai proses login di provider
- Log info saat login berhasil
- Log warning saat login gagal dengan pesan error
- Log error untuk unexpected error
- Log info saat memulai logout
- Log debug saat clearing state

**Provider lainnya:**
- `currentUserProvider`: Log debug saat mengambil profil user
- `preferencesProvider`: Log debug saat mengambil preferences
- `authStateProvider`: Log debug status autentikasi

## Cara Menggunakan Logger

### Level Logging
- **Debug**: Informasi detail untuk debugging (`AppLogger.debug()`)
- **Info**: Informasi umum operasi (`AppLogger.info()`)
- **Warning**: Peringatan untuk situasi tidak normal (`AppLogger.warning()`)
- **Error**: Error yang terjadi (`AppLogger.error()`)

### Format Log
```dart
AppLogger.info('Message', tag: 'ComponentName');
AppLogger.error('Error message', tag: 'ComponentName', error: exceptionObject);
```

### Tag yang Digunakan
- `AuthService`: Untuk semua operasi di auth service
- `RegisterNotifier`: Untuk operasi registrasi di provider
- `LoginNotifier`: Untuk operasi login di provider
- `CurrentUserProvider`: Untuk current user provider
- `PreferencesProvider`: Untuk preferences provider
- `AuthStateProvider`: Untuk auth state provider

## Debugging dengan Logger

### 1. Melihat Flow Registrasi
Cari log dengan tag `AuthService` dan `RegisterNotifier`:
```
[AuthService] Starting user registration
[RegisterNotifier] Starting registration process in provider
[AuthService] Registration request for email: user@example.com
[AuthService] Creating user with Supabase Auth
[AuthService] User created successfully with ID: xxxxx
[AuthService] Inserting user data to users table
[AuthService] User registration completed successfully
[RegisterNotifier] Registration successful in provider
```

### 2. Melihat Flow Login
Cari log dengan tag `AuthService` dan `LoginNotifier`:
```
[LoginNotifier] Starting login process in provider
[AuthService] Starting user login
[AuthService] Login attempt for email: user@example.com
[AuthService] User authenticated successfully
[AuthService] User data retrieved successfully
[LoginNotifier] Login successful in provider
```

### 3. Mendeteksi Error
Cari log dengan level `error` atau `warning`:
```
[AuthService] Auth exception during registration: Email already registered
[AuthService] Database error during registration: unique_violation
[RegisterNotifier] Registration failed in provider: Email sudah terdaftar
```

## Konfigurasi Logger

Logger menggunakan `dart:developer` dengan level yang berbeda:
- Debug: level 500
- Info: level 800  
- Warning: level 900
- Error: level 1000

Untuk melihat log di console, pastikan filter log di IDE/terminal Anda diset untuk menampilkan level yang diinginkan.

## Error Tracking

Dengan sistem logging ini, Anda dapat:

1. **Melacak flow lengkap** dari registrasi/login
2. **Mengidentifikasi titik kegagalan** dengan cepat
3. **Melihat error detail** beserta stack trace
4. **Monitoring performa** operasi auth
5. **Debug masalah integrasi** dengan Supabase

## Tips Debugging

1. **Filter berdasarkan tag** untuk fokus pada komponen tertentu
2. **Cari pattern error** yang berulang
3. **Perhatikan sequence log** untuk memahami flow
4. **Gunakan search functionality** di IDE untuk mencari log spesifik
5. **Monitor log real-time** saat testing fitur

Sistem logging ini akan sangat membantu dalam development dan production untuk mengidentifikasi dan mengatasi masalah autentikasi dengan cepat.
