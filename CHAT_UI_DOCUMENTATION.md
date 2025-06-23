# UI Chat - Dokumentasi

## Overview
UI Chat yang telah dibuat mencakup chat list page, chat page, dan chat bubble widget yang modern dan responsif.

## Komponen yang telah dibuat:

### 1. Chat List Page (`chat_list_page.dart`)
- **Lokasi**: `/Users/khoirulfahmi/flutter-project/nimbrung_mobile/lib/presentation/screens/chat/chat_list_page.dart`
- **Fitur**:
  - Daftar percakapan dengan avatar, nama, pesan terakhir, dan waktu
  - Status online indicator
  - Badge notifikasi untuk pesan yang belum dibaca
  - Search bar untuk mencari percakapan
  - Floating action button untuk memulai chat baru
  - Group chat support dengan indicator
  - Mark as read functionality

### 2. Chat Page (`chat_page.dart`)
- **Lokasi**: `/Users/khoirulfahmi/flutter-project/nimbrung_mobile/lib/presentation/screens/chat/chat_page.dart`
- **Fitur**:
  - Custom app bar dengan avatar dan status online
  - Chat bubbles untuk pesan masuk dan keluar
  - Input field dengan emoji support
  - Send button dengan animasi
  - Reply functionality
  - Typing indicator
  - Message status (sent, delivered, read)
  - Scroll to bottom functionality

### 3. Chat Bubble Widget (`chat_bubble.dart`)
- **Lokasi**: `/Users/khoirulfahmi/flutter-project/nimbrung_mobile/lib/presentation/widgets/chat_bubble.dart`
- **Fitur**:
  - Design yang berbeda untuk pesan masuk dan keluar
  - Avatar support
  - Timestamp display
  - Message status icons
  - Reply indicator
  - Long press actions
  - Different message types (text, image, file, audio)

### 4. Chat Model (`chat_model.dart`)
- **Lokasi**: `/Users/khoirulfahmi/flutter-project/nimbrung_mobile/lib/presentation/models/chat_model.dart`
- **Fitur**:
  - ChatMessage model with complete properties
  - ChatConversation model for chat list
  - State management dengan Riverpod
  - Dummy data untuk testing
  - Message status enum
  - Message type enum

## Navigasi Chat

### Routing Configuration
Chat routing telah dikonfigurasi dalam `app_route.dart`:

```dart
// Nested route untuk chat list
GoRoute(
  path: 'chat',
  name: RouteNames.chatList,
  builder: (context, state) => const ChatListPage(),
  routes: [
    GoRoute(
      path: ':chatId',
      name: RouteNames.chatDetail,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final chatTitle = state.uri.queryParameters['title'] ?? 'Chat';
        final chatAvatar = state.uri.queryParameters['avatar'];
        return ChatPage(
          chatId: chatId,
          chatTitle: chatTitle,
          chatAvatar: chatAvatar,
        );
      },
    ),
  ],
),
```

### URL Structure
- Chat List: `/home/chat`
- Individual Chat: `/home/chat/:chatId?title=ChatTitle&avatar=AvatarUrl`

### Navigation Examples
```dart
// Ke chat list
context.go('/home/chat');

// Ke chat tertentu dengan parameter
context.go('/home/chat/user123?title=John Doe&avatar=avatar_url');
```

## Integration Points

### 1. Home Page
Tombol chat telah ditambahkan di home page setelah tombol share:
```dart
GestureDetector(
  onTap: () {
    context.go('/home/chat');
  },
  child: Container(
    // Chat button styling
  ),
),
```

### 2. Bottom Navigation
Bottom navigation akan tersembunyi otomatis pada:
- Chat list page (`/home/chat`)
- Individual chat pages (`/home/chat/:chatId`)

Rule tersembunyi telah ditambahkan di `main_screen.dart`:
```dart
bool _shouldHideBottomNavigation(String location) {
  return location.contains('/home/discussion') ||
      location.contains('/home/detail-reading') ||
      location.contains('/home/chat/') ||
      location.contains('/standalone-');
}
```

## Dummy Data
Aplikasi menggunakan dummy data untuk testing:
- 6 percakapan contoh (individual dan group)
- Sample messages dengan berbagai status
- Profile pictures dari randomuser.me

## Design Features

### Chat List
- **Modern card design** dengan shadow dan rounded corners
- **Online status indicator** dengan green dot
- **Unread badge** dengan counter
- **Time formatting** yang user-friendly (sekarang, 5m, 2j, 1h)
- **Group chat icons** untuk membedakan dengan individual chat

### Chat Page
- **Bubble design** yang berbeda untuk sender dan receiver
- **Smooth animations** untuk send button dan scroll
- **Status icons** untuk message delivery
- **Reply functionality** dengan visual indicator
- **Custom app bar** dengan avatar dan online status

### Color Scheme
Menggunakan `AppColors.primary` dari theme aplikasi untuk konsistensi:
- Primary color untuk sent messages dan accents
- White background untuk received messages
- Grey colors untuk timestamps dan secondary text

## Future Enhancements

### Immediate Todos
1. **Backend Integration**: Connect to real chat API
2. **Real-time Updates**: Implement WebSocket atau Firebase for live chat
3. **Media Sharing**: Add image, file, dan audio message support
4. **Push Notifications**: Untuk new messages
5. **Search Functionality**: Search dalam percakapan dan global

### Advanced Features
1. **Voice Messages**: Record dan playback audio
2. **Video Calls**: Integration dengan video calling service
3. **Message Reactions**: Emoji reactions pada messages
4. **Message Threading**: Reply threads untuk group chats
5. **Chat Backup**: Local storage dan cloud backup
6. **End-to-End Encryption**: Security untuk private messages

## Testing
Untuk test UI chat:
1. Run aplikasi
2. Navigate ke home page
3. Tap tombol chat (chat bubble icon)
4. Browse chat list
5. Tap pada salah satu conversation
6. Test send message functionality

## Dependencies
Chat UI menggunakan:
- `flutter_riverpod` untuk state management
- `go_router` untuk navigation
- `flutter_svg` untuk icons (jika ada)
- Built-in Flutter Material widgets

Semua dependencies sudah ada dalam project ini.
