# User Information Widgets

This documentation explains how to use the reusable user information widgets in the Nimbrung Mobile app.

## Available Widgets

### 1. UserAvatar

Displays the authenticated user's avatar with customizable styling.

```dart
UserAvatar(
  radius: 40,
  borderColor: Colors.white,
  borderWidth: 2,
  fallbackImageUrl: 'https://example.com/default-avatar.png',
)
```

### 2. UserDisplayName

Shows the user's display name (fullname or username based on preference).

```dart
UserDisplayName(
  preferUsername: false, // If true, prefers username over fullname
  fallbackText: 'Guest User',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
)
```

### 3. UserEmail

Displays the authenticated user's email address.

```dart
UserEmail(
  style: TextStyle(color: Colors.grey),
  fallbackEmail: 'guest@example.com',
)
```

### 4. UserBio

Shows the user's biography/about section.

```dart
UserBio(
  style: TextStyle(fontSize: 14),
  fallbackBio: 'No bio available',
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
)
```

### 5. UserPreference

Displays the user's preference/major/field of study from the joined preference table.

```dart
UserPreference(
  style: TextStyle(color: Colors.blue),
  fallbackPreference: 'General',
)
```

### 6. UserInfoCard

A comprehensive widget that combines all user information.

```dart
UserInfoCard(
  showAvatar: true,
  showName: true,
  showEmail: true,
  showBio: true,
  showPreference: true,
  avatarRadius: 50,
  padding: EdgeInsets.all(16),
  fallbackBio: 'Welcome to Nimbrung!',
  fallbackPreference: 'Student',
)
```

## Features

- **Reactive**: All widgets automatically update when the authentication state changes
- **Fallback Support**: Each widget supports fallback values for when user data is not available
- **Customizable**: Extensive styling options for each widget
- **Type Safe**: Uses Riverpod for state management with proper typing
- **Performance**: Efficient rebuilding only when authentication state changes

## Authentication States

The widgets handle these authentication states:

1. **AppAuthAuthenticated**: Shows actual user data
2. **Other states**: Shows fallback values

## Example Usage in Profile Page

```dart
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // User avatar
          UserAvatar(radius: 60),

          // User name
          UserDisplayName(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // User preference
          UserPreference(
            fallbackPreference: 'Psikologi',
          ),

          // User bio
          UserBio(
            fallbackBio: 'No bio added yet.',
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
```

## Notes

- All widgets are Consumer widgets that automatically listen to authentication state changes
- The `preferenceName` field is automatically loaded from the joined preference table in your backend
- Avatar images are loaded from URLs, with automatic fallback to default images
- All styling is customizable through the respective style parameters
- The preference name is directly available from the User entity's `preferenceName` field
