# Perubahan Struktur Routing - Nested Navigation

## Masalah yang Diperbaiki
Sebelumnya, route bertingkat seperti `/home/discussion` tidak dapat diakses karena menggunakan struktur routing yang tidak mendukung nested navigation dengan baik.

## Perubahan yang Dibuat

### 1. **app_route.dart** - Struktur Routing Baru
- ✅ Mengubah `initialLocation` dari `/` ke `/home`
- ✅ Memindahkan `discussionRoom` dan `detailReading` sebagai nested routes di bawah `/home`
- ✅ Menambahkan standalone routes untuk halaman fullscreen
- ✅ Route paths yang sekarang tersedia:
  - `/home` - Homepage dengan bottom navigation
  - `/home/discussion` - Discussion room (nested, tanpa bottom nav)
  - `/home/detail-reading/:reviewId` - Detail reading (nested, tanpa bottom nav)
  - `/standalone-discussion` - Discussion room fullscreen
  - `/standalone-detail/:reviewId` - Detail reading fullscreen

### 2. **main_screen.dart** - Smart Bottom Navigation
- ✅ Menambahkan logic untuk menyembunyikan bottom navigation pada nested routes
- ✅ Method `_shouldHideBottomNavigation()` untuk mendeteksi route yang perlu menyembunyikan bottom nav
- ✅ Bottom navigation akan hilang otomatis ketika berada di:
  - `/home/discussion`
  - `/home/detail-reading/*`
  - Routes yang dimulai dengan `/standalone-`

### 3. **home_page.dart** - Navigasi Terbarui
- ✅ Mengubah navigasi button "Mulai Nimbrung" dari `context.goNamed()` ke `context.go('/home/discussion')`
- ✅ Membersihkan import yang tidak digunakan

### 4. **resension.dart** - Detail Navigation
- ✅ Mengubah navigasi ke detail reading menggunakan `context.go('/home/detail-reading/${review.id}')`
- ✅ Membersihkan import yang tidak digunakan

## Cara Menggunakan

### Navigasi ke Discussion Room
```dart
// Nested route (dengan bottom nav tersembunyi)
context.go('/home/discussion');

// Standalone route (fullscreen)
context.go('/standalone-discussion');
```

### Navigasi ke Detail Reading
```dart
// Nested route (dengan bottom nav tersembunyi)
context.go('/home/detail-reading/123');

// Standalone route (fullscreen)
context.go('/standalone-detail/123');
```

### Navigasi Kembali
```dart
// Dari nested route, akan kembali ke /home
context.pop();

// Atau kembali ke home secara eksplisit
context.go('/home');
```

## Keuntungan Struktur Baru

1. **URL yang Semantik**: `/home/discussion` lebih jelas daripada `/discussion-room`
2. **Bottom Navigation Otomatis**: Tersembunyi otomatis di halaman yang sesuai
3. **Konsistensi**: Struktur hierarchical yang jelas
4. **Fleksibilitas**: Mendukung both nested dan standalone routes
5. **Debugging**: URL di browser/logs lebih mudah dipahami

## Testing

Untuk memastikan routing bekerja dengan baik:

1. **Test Nested Navigation**:
   - Dari home → discussion room (bottom nav hilang)
   - Dari home → detail reading (bottom nav hilang)
   - Back button harus kembali ke home (bottom nav muncul)

2. **Test URL Direct Access**:
   - Akses langsung `/home/discussion` di browser
   - Akses langsung `/home/detail-reading/123`

3. **Test Bottom Navigation**:
   - Cek bottom nav tersembunyi di nested routes
   - Cek bottom nav muncul di main routes

## Notes

- Semua perubahan backward compatible
- Route names (`RouteNames.discussionRoom`, dll.) masih tersedia untuk compatibility
- Debug logging tetap aktif untuk monitoring
