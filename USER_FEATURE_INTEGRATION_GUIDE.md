# User Feature Integration Guide

This document explains how to use the new User feature after the Clean Architecture separation.

## Architecture Overview

The User feature has been separated from Auth and now handles all user management functionality:

### User Feature Structure

```
lib/features/user/
├── domain/
│   ├── entities/
│   │   ├── user.dart           # User entity
│   │   └── preference.dart     # Preference entity
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
│       ├── get_user_profile.dart
│       ├── update_profile.dart
│       ├── update_avatar.dart
│       ├── get_preferences.dart
│       └── search_users.dart
├── data/
│   ├── models/
│   ├── datasources/
│   ├── repositories/
│   └── services/
└── presentation/
    ├── notifiers/
    ├── providers/
    ├── state/
    └── widgets/
```

### Auth Feature (Cleaned)

```
lib/features/auth/
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart    # Only authentication methods
│   └── usecases/
│       ├── login.dart
│       ├── register.dart
│       ├── logout.dart
│       └── get_current_user.dart   # Returns User entity
└── presentation/
    ├── notifiers/
    │   └── app_auth_notifier.dart  # Global auth state
    └── providers/
        └── auth_providers.dart     # Only auth-related providers
```

## Key Providers

### Auth Providers (Authentication Only)

```dart
// Auth state - use this to check authentication status
final appAuthNotifierProvider = StateNotifierProvider<AppAuthNotifier, AppAuthState>((ref) {
  // ... authentication state management
});

// Check if user is logged in
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  // ... check login status
});
```

### User Providers (User Management)

```dart
// Current authenticated user ID (derived from auth state)
final currentUserProvider = Provider<String?>((ref) {
  final authState = ref.watch(appAuthNotifierProvider);
  if (authState is AppAuthAuthenticated) {
    return authState.user.id;
  }
  return null;
});

// User profile management
final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, UserState>((ref) {
  // ... user profile state management
});

// Automatically load current user profile when authenticated
final currentUserProfileProvider = Provider<UserState>((ref) {
  final currentUserId = ref.watch(currentUserProvider);
  if (currentUserId != null) {
    ref.watch(userProfileNotifierProvider.notifier).getUserProfile(currentUserId);
  }
  return ref.watch(userProfileNotifierProvider);
});

// Preferences from database
final preferencesProvider = FutureProvider<List<Preference>>((ref) async {
  // ... load preferences from database
});

// User search functionality
final userSearchNotifierProvider = StateNotifierProvider<UserSearchNotifier, UserState>((ref) {
  // ... user search state management
});
```

## How to Use

### 1. Checking Authentication Status

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    if (authState is AppAuthAuthenticated) {
      // User is logged in, show authenticated content
      return AuthenticatedContent();
    } else if (authState is AppAuthUnauthenticated) {
      // User is not logged in, show login screen
      return LoginScreen();
    } else {
      // Loading or error state
      return LoadingScreen();
    }
  }
}
```

### 2. Getting Current User Info (for display)

For basic user info display (name, avatar, email), use the reusable widgets:

```dart
class ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        UserAvatar(radius: 40),
        UserDisplayName(style: TextStyle(fontSize: 24)),
        UserEmail(style: TextStyle(color: Colors.grey)),
        UserPreference(style: TextStyle(color: Colors.blue)),
      ],
    );
  }
}
```

### 3. Managing User Profile

```dart
class EditProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileNotifierProvider);
    final currentUserId = ref.watch(currentUserProvider);

    return Scaffold(
      body: userState.when(
        initial: () => Center(child: Text('Ready to load profile')),
        loading: () => Center(child: CircularProgressIndicator()),
        loaded: (user) => ProfileForm(user: user),
        error: (message) => Center(child: Text('Error: $message')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentUserId != null) {
            ref.read(userProfileNotifierProvider.notifier).updateProfile(
              userId: currentUserId,
              bio: 'Updated bio',
              // ... other fields
            );
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
```

### 4. Loading Preferences

```dart
class PreferenceSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return preferencesAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading preferences'),
      data: (preferences) => DropdownButton<String>(
        items: preferences.map((pref) => DropdownMenuItem(
          value: pref.id,
          child: Text(pref.preferencesName ?? 'Unknown'),
        )).toList(),
        onChanged: (value) {
          // Handle preference selection
        },
      ),
    );
  }
}
```

### 5. User Search

```dart
class UserSearchPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onSubmitted: (query) {
            ref.read(userSearchNotifierProvider.notifier).searchUsers(query);
          },
        ),
      ),
      body: searchState.when(
        initial: () => Center(child: Text('Search for users')),
        loading: () => Center(child: CircularProgressIndicator()),
        loaded: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) => UserTile(user: users[index]),
        ),
        error: (message) => Center(child: Text('Error: $message')),
      ),
    );
  }
}
```

## State Management

### User States

```dart
abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final User user;  // Single user
  // OR
  final List<User> users;  // Multiple users (for search)
}
class UserError extends UserState {
  final String message;
}
```

### Auth States

```dart
abstract class AppAuthState {}
class AppAuthInitial extends AppAuthState {}
class AppAuthLoading extends AppAuthState {}
class AppAuthAuthenticated extends AppAuthState {
  final User user;  // Basic user info for auth
}
class AppAuthUnauthenticated extends AppAuthState {}
class AppAuthError extends AppAuthState {
  final String message;
}
```

## Migration from Old Code

### Before (Old Auth-based approach)

```dart
// DON'T USE - Old approach
final currentUserState = ref.watch(currentUserNotifierProvider);
if (currentUserState is CurrentUserLoaded) {
  final user = currentUserState.user;
}

// DON'T USE - Old providers
ref.read(profileUpdateWithImageNotifierProvider.notifier).updateProfile(...);
```

### After (New User feature approach)

```dart
// USE - New approach for basic user info
final authState = ref.watch(appAuthNotifierProvider);
if (authState is AppAuthAuthenticated) {
  final user = authState.user;  // Basic info from auth
}

// USE - For detailed user management
final currentUserId = ref.watch(currentUserProvider);
ref.read(userProfileNotifierProvider.notifier).updateProfile(...);

// USE - For UI components
UserAvatar(), UserDisplayName(), UserEmail(), etc.
```

## Best Practices

1. **Use Auth for Authentication**: Login, logout, session management
2. **Use User for Profile Management**: Update bio, avatar, preferences
3. **Use Reusable Widgets**: For displaying user info in UI
4. **State Integration**: Auth provides user ID, User feature manages detailed profile
5. **Error Handling**: Both features have their own error states
6. **Loading States**: Show appropriate loading indicators for each operation

## Files Updated in Migration

### Created/Moved to User Feature:

- `lib/features/user/` (entire feature)
- All user management use cases, repositories, models
- User profile, preferences, search functionality

### Updated in Auth Feature:

- Removed user management methods from `AuthRepository`
- Cleaned up `auth_providers.dart` to only include auth-related providers
- Updated `AppAuthNotifier` to use User entity from user feature

### Updated UI Components:

- `register_update_page.dart` - Uses new user providers
- All user widgets continue to work with auth state
- Settings and profile pages use new user providers

This separation provides better code organization, clearer responsibilities, and easier maintenance.
