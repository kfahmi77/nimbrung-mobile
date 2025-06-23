# Chat UI - Visual Design Guide

## Design System

### Color Palette
- **Primary**: AppColors.primary (Biru aplikasi)
- **Background**: Colors.grey[50] (Light grey background)
- **Cards**: Colors.white dengan shadow
- **Text Primary**: Colors.black87
- **Text Secondary**: Colors.grey[600]
- **Online Status**: Colors.green
- **Unread Badge**: AppColors.primary

### Typography
- **Chat Title**: 16px, FontWeight.w600
- **Last Message**: 14px, FontWeight.normal
- **Timestamp**: 12px, Colors.grey[600]
- **Unread Count**: 12px, FontWeight.bold, White

### Spacing
- **Card Padding**: 16px horizontal, 12px vertical
- **Avatar Size**: 50px (radius 25)
- **Online Indicator**: 14px dengan 2px white border
- **Margin Between Cards**: 2px vertical

## Chat List Layout

```
┌─────────────────────────────────────────┐
│  ← Pesan                     🔍  ⋮     │  <- App Bar
├─────────────────────────────────────────┤
│  🔍 Cari percakapan...                  │  <- Search Bar
├─────────────────────────────────────────┤
│  👤● Dr. Sarah Chen           2m    [2] │  <- Chat Item
│  Exactly! Dan ini juga ber...            │
├─────────────────────────────────────────┤
│  👥  Grup Diskusi Psikologi  15m   [5] │  <- Group Chat
│  Ahmad: Saya setuju dengan...            │
├─────────────────────────────────────────┤
│  👤  Prof. David Wilson      1j        │  <- Read Chat
│  Terima kasih untuk sharing...           │
└─────────────────────────────────────────┘
                                        💬   <- FAB
```

## Chat Page Layout

```
┌─────────────────────────────────────────┐
│  ← 👤● Sarah Chen              📞  ⋮   │  <- Chat Header
├─────────────────────────────────────────┤
│                        Halo! 👋    ✓✓  │  <- My Message
│                           09:30         │
├─────────────────────────────────────────┤
│  Hei! Gimana kabarnya?           ✓✓    │  <- Their Message  
│  09:31                                   │
├─────────────────────────────────────────┤
│                   Baik kok! Kamu?  ✓✓  │  <- My Message
│                           09:32         │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐ │
│  │  💬 Type a message...          😊  📎│ │  <- Input Bar
│  │                               [🎤] │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Chat Bubble Design

### My Messages (Right Side)
```
                    ┌──────────────────────┐
                    │  Halo! Gimana kabar? │  <- Blue background
                    │                   ✓✓ │  <- Status icons
                    └──────────────────────┘
                              09:30           <- Timestamp
```

### Their Messages (Left Side)
```
👤  ┌──────────────────────┐
    │  Hei! Baik kok       │  <- White background  
    │                      │
    └──────────────────────┘
    09:31                    <- Timestamp
```

## Interactive States

### Hover/Press States
- **Chat List Items**: Slight grey background on press
- **Send Button**: Scale animation (0.8 → 1.0)
- **Message Bubbles**: Haptic feedback on long press

### Loading States
- **Send Message**: Loading spinner in send button
- **Chat List**: Shimmer effect while loading
- **Message Status**: Progressive status updates

### Error States
- **Failed Message**: Red indicator dengan retry option
- **Network Error**: Toast notification
- **Loading Failed**: Retry button di chat list

## Animations

### Send Button
```dart
AnimationController(duration: Duration(milliseconds: 200))
Tween<double>(begin: 0.8, end: 1.0)
Curve: Curves.elasticOut
```

### Scroll Behavior
- **Auto-scroll** ke bottom saat ada pesan baru
- **Smooth scroll** dengan duration 300ms
- **Scroll indicator** untuk pesan baru

### Page Transitions
- **Slide transition** dari chat list ke chat page
- **Fade transition** untuk modal dialogs
- **Scale transition** untuk floating action button

## Responsive Design

### Mobile Portrait (Default)
- **Full width** chat bubbles dengan max 80% width
- **Single column** layout
- **Bottom input** bar dengan soft keyboard support

### Mobile Landscape
- **Reduced padding** untuk lebih banyak content
- **Compact header** dengan smaller avatars
- **Optimized keyboard** interaction

### Tablet Support
- **Max width constraint** untuk chat bubbles (600px)
- **Centered content** dengan side margins
- **Larger touch targets** untuk better accessibility

## Accessibility

### Screen Reader Support
- **Semantic labels** untuk semua interactive elements
- **Message content** properly announced
- **Timestamp information** included in announcements

### High Contrast Mode
- **Border outlines** untuk chat bubbles
- **Stronger color contrast** untuk text
- **Alternative indicators** untuk status

### Keyboard Navigation
- **Tab order** yang logical
- **Enter key** untuk send message
- **Arrow keys** untuk navigation (jika applicable)

## Performance Optimizations

### List Performance
- **ListView.builder** untuk efficient scrolling
- **RepaintBoundary** untuk chat bubbles
- **Cached images** untuk avatars

### Memory Management
- **Dispose controllers** properly
- **Limit message history** di memory
- **Lazy loading** untuk older messages

### Network Optimizations
- **Image caching** untuk avatars
- **Debounced typing** indicators
- **Optimistic updates** untuk sent messages

## Testing Checklist

### Functional Testing
- [ ] Navigate to chat list
- [ ] Open individual chat
- [ ] Send text message
- [ ] Receive message
- [ ] Message status updates
- [ ] Online status indicator
- [ ] Unread count updates
- [ ] Search functionality

### UI Testing
- [ ] Proper bubble alignment
- [ ] Avatar display
- [ ] Timestamp formatting
- [ ] Status icon visibility
- [ ] Keyboard interaction
- [ ] Scroll behavior
- [ ] Bottom navigation hiding

### Integration Testing
- [ ] GoRouter navigation
- [ ] State persistence
- [ ] Deep linking support
- [ ] Back button behavior

### Performance Testing
- [ ] Smooth scrolling dengan 100+ messages
- [ ] Memory usage dengan long chat history
- [ ] Startup time dari cold start
- [ ] Animation frame rate
