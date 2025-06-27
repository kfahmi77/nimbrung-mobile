# Clean Architecture Implementation for Authentication Module

This document describes the Clean Architecture implementation for the authentication module using Riverpod for state management.

## Architecture Overview

The authentication module follows Clean Architecture principles with clear separation of concerns:

```
features/auth/
├── data/                    # Data Layer
│   ├── datasources/        # External data sources
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/                 # Domain Layer (Business Logic)
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/          # Business use cases
└── presentation/           # Presentation Layer
    ├── notifiers/         # State management with Riverpod
    ├── providers/         # Dependency injection
    └── state/             # State definitions
```

## Layer Responsibilities

### 1. Domain Layer (Business Logic)

- **Entities**: Core business objects (User, Preference)
- **Use Cases**: Specific business operations (Login, Register, UpdateProfile)
- **Repository Interfaces**: Contracts for data access

### 2. Data Layer

- **Data Sources**: External API integration (Supabase)
- **Models**: Data transfer objects with JSON serialization
- **Repository Implementations**: Concrete implementations of domain contracts

### 3. Presentation Layer

- **State**: State definitions using sealed classes
- **Notifiers**: StateNotifier classes for state management
- **Providers**: Riverpod providers for dependency injection

## Key Components

### Use Cases

- `LoginUseCase`: Handle user authentication
- `RegisterUseCase`: Handle user registration
- `UpdateProfileUseCase`: Handle profile updates
- `GetCurrentUserUseCase`: Get current authenticated user
- `GetPreferencesUseCase`: Get available preferences

### State Management

- Uses Riverpod StateNotifier for reactive state management
- Immutable state classes with clear success/loading/error states
- Automatic state updates throughout the UI

### Dependency Injection

- All dependencies injected through Riverpod providers
- Easy testing and mocking
- Single source of truth for dependencies

## Usage Examples

### Using in UI Components

```dart
class RegisterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerNotifierProvider);

    // Listen to state changes
    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (next is RegisterSuccess) {
        // Handle success
        context.go('/register-update');
      } else if (next is RegisterFailure) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // UI components
          ElevatedButton(
            onPressed: registerState is RegisterLoading ? null : () {
              // Call use case through notifier
              ref.read(registerNotifierProvider.notifier).register(
                email: email,
                password: password,
                username: username,
                fullname: fullname,
                gender: gender,
              );
            },
            child: Text(registerState is RegisterLoading ? 'Loading...' : 'Register'),
          ),
        ],
      ),
    );
  }
}
```

### Getting Preferences

```dart
class PreferenceDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return preferencesAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (preferences) => DropdownButton<String>(
        items: preferences.map((pref) => DropdownMenuItem(
          value: pref.id,
          child: Text(pref.preferencesName ?? ''),
        )).toList(),
        onChanged: (value) {
          // Handle selection
        },
      ),
    );
  }
}
```

## Benefits

1. **Separation of Concerns**: Each layer has clear responsibilities
2. **Testability**: Easy to unit test business logic in isolation
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same pattern
5. **Dependency Inversion**: High-level modules don't depend on low-level modules

## Migration Notes

- Old providers are replaced with new Clean Architecture providers
- State management moved from simple StateNotifier to structured state classes
- Business logic extracted into use cases for better testability
- Data access abstracted through repository pattern

## Future Improvements

1. Add local data sources for caching
2. Implement error handling middleware
3. Add logging interceptors
4. Create automated tests for each layer
5. Add analytics tracking for user actions
