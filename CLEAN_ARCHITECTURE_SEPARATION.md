# Clean Architecture Separation: Auth vs User Features

## Overview

This document describes the separation of authentication and user management concerns according to Clean Architecture principles.

## Architecture Separation

### Auth Feature (`lib/features/auth/`)

**Responsibilities:**

- User authentication (login, register, logout)
- Session management
- Password reset
- Authentication state management

**Components:**

#### Domain Layer

- **Entities:** None (uses User entity from user feature)
- **Repository:** `AuthRepository` - only auth operations
- **Use Cases:**
  - `LoginUseCase` - handle user login
  - `RegisterUseCase` - handle user registration
  - `LogoutUseCase` - handle user logout
  - `GetCurrentUserUseCase` - get authenticated user
  - `ResetPasswordUseCase` - handle password reset

#### Data Layer

- **Data Sources:** `AuthRemoteDataSource` - Supabase auth operations
- **Repository Implementation:** `AuthRepositoryImpl`
- **Models:** Uses UserModel from user feature

#### Presentation Layer

- **Notifiers:**
  - `AppAuthNotifier` - global authentication state
  - `LoginNotifier` - login form state
  - `RegisterNotifier` - registration form state
- **States:** `AppAuthState` and specific auth states
- **Pages:** Login, Register, Splash screens

---

### User Feature (`lib/features/user/`)

**Responsibilities:**

- User profile management
- User preferences
- Avatar management
- User search and discovery
- Future social features (follow/unfollow)

**Components:**

#### Domain Layer

- **Entities:**
  - `User` - user profile data
  - `Preference` - user reading preferences
- **Repository:** `UserRepository` - user management operations
- **Use Cases:**
  - `GetUserProfileUseCase`
  - `UpdateProfileUseCase`
  - `UpdateAvatarUseCase`
  - `GetPreferencesUseCase`
  - `SearchUsersUseCase`

#### Data Layer

- **Data Sources:** `UserRemoteDataSource` - user operations
- **Services:** `UserImageService` - avatar upload/management
- **Repository Implementation:** `UserRepositoryImpl`
- **Models:** `UserModel`, `PreferenceModel`

#### Presentation Layer

- **Notifiers:**
  - `UserProfileNotifier` - user profile state
  - `PreferenceNotifier` - preferences state
  - `UserSearchNotifier` - user search state
- **States:** `UserState`, `PreferenceState`
- **Pages:** Profile, Settings, User Info pages

## Integration Points

### Shared Dependencies

1. **User Entity:** Both features use the same User entity from `user/domain/entities/user.dart`
2. **Core Services:** Both use shared services like `ImageUploadService`
3. **Authentication State:** User feature can access current user ID from auth state

### Data Flow

```
Auth Feature (Login) → User Feature (Profile)
     ↓                        ↓
  User ID              Profile Management
     ↓                        ↓
Global Auth State ←→ User Profile State
```

### Provider Integration

```dart
// Auth provides user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(appAuthNotifierProvider);
  return authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
});

// User feature uses the current user ID
final currentUserProfileProvider = FutureProvider<User?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final userNotifier = ref.read(userProfileNotifierProvider.notifier);
  await userNotifier.getUserProfile(userId);

  final userState = ref.read(userProfileNotifierProvider);
  return userState.maybeWhen(
    loaded: (user) => user,
    orElse: () => null,
  );
});
```

## Benefits of This Separation

### 1. Single Responsibility Principle

- Auth feature: Only handles authentication
- User feature: Only handles user data management

### 2. Dependency Inversion

- Both features depend on abstractions (repositories)
- Easy to swap implementations (e.g., Firebase auth instead of Supabase)

### 3. Testability

- Each feature can be tested independently
- Mock repositories for unit testing

### 4. Scalability

- Easy to add new user-related features (social, notifications)
- Auth logic remains unchanged when adding user features

### 5. Maintainability

- Clear boundaries between authentication and user management
- Easier to debug and modify specific functionality

## Migration Steps

### Phase 1: ✅ Completed

- Created user feature structure
- Moved user entities to user feature
- Created user-specific use cases and repositories
- Updated auth feature to focus only on authentication

### Phase 2: Next Steps

- Update existing UI components to use new user providers
- Migrate profile-related notifiers to user feature
- Update settings and profile pages to use user feature
- Remove old user management code from auth feature

### Phase 3: Enhancements

- Add user search functionality
- Implement social features (follow/unfollow)
- Add advanced user management features

## File Structure

```
lib/features/
├── auth/                          # Authentication only
│   ├── domain/
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   └── usecases/
│   │       ├── login.dart
│   │       ├── register.dart
│   │       ├── logout.dart
│   │       └── get_current_user.dart
│   ├── data/
│   │   ├── datasources/
│   │   ├── repositories/
│   │   └── services/
│   └── presentation/
│       ├── notifiers/
│       ├── providers/
│       └── pages/
└── user/                          # User management
    ├── domain/
    │   ├── entities/
    │   │   ├── user.dart
    │   │   └── preference.dart
    │   ├── repositories/
    │   │   └── user_repository.dart
    │   └── usecases/
    │       ├── get_user_profile.dart
    │       ├── update_profile.dart
    │       ├── update_avatar.dart
    │       ├── get_preferences.dart
    │       └── search_users.dart
    ├── data/
    │   ├── datasources/
    │   ├── repositories/
    │   ├── models/
    │   └── services/
    └── presentation/
        ├── notifiers/
        ├── providers/
        ├── states/
        └── pages/
```

## Usage Examples

### Getting Current User Profile

```dart
// In a widget
Consumer(
  builder: (context, ref, child) {
    final userState = ref.watch(userProfileNotifierProvider);

    return userState.when(
      initial: () => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
      loaded: (user) => UserProfileWidget(user: user),
      error: (message) => ErrorWidget(message),
    );
  },
)
```

### Updating User Profile

```dart
// In a form submission
final userNotifier = ref.read(userProfileNotifierProvider.notifier);
await userNotifier.updateProfile(
  userId: currentUserId,
  fullname: fullnameController.text,
  bio: bioController.text,
);
```

This architecture provides a clean separation of concerns while maintaining the ability to share data between features when needed.
