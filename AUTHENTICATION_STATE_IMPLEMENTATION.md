# Authentication State Management Implementation

## 🎯 **Overview**

Implementasi state management untuk authentication dengan routing otomatis berdasarkan status login user menggunakan Riverpod dan GoRouter.

## 📋 **Features yang Diimplementasikan:**

### ✅ **Authentication State Management**

- App-wide authentication state menggunakan `AppAuthNotifier`
- Automatic auth check saat app startup
- Real-time auth status monitoring
- Smooth state transitions

### ✅ **Automatic Routing**

- **Splash Screen** → Check auth status → Route ke halaman yang sesuai
- **Authenticated User** → Home page (jika profile complete) atau Register Update page
- **Unauthenticated User** → Login page
- **Logout** → Otomatis kembali ke splash/login

### ✅ **UI State Management**

- Loading states dengan smooth animations
- Error handling dengan retry functionality
- Success state dengan proper navigation
- Logout confirmation dialogs

## 🏗️ **Architecture Structure:**

```
lib/
  features/
    auth/
      presentation/
        notifiers/
          app_auth_notifier.dart         # ✅ App-wide auth state
          login_notifier.dart           # ✅ Updated dengan auth integration
          register_notifier.dart        # ✅ Updated dengan auth integration
        providers/
          auth_providers.dart           # ✅ Updated dengan app auth provider
  presentation/
    screens/
      splash/
        splash_screen.dart              # ✅ Authentication checker
      login/
        login_page.dart                 # ✅ Updated dengan auth listener
      main_screen.dart                  # ✅ Updated dengan logout functionality
    widgets/
      logout_test_button.dart           # ✅ Testing logout functionality
    routes/
      app_route.dart                    # ✅ Updated dengan splash route
      route_name.dart                   # ✅ Added splash route name
```

## 🔄 **Authentication Flow:**

### 1. **App Startup Flow:**

```
App Start → Splash Screen → Check Auth Status
                ↓
            Authenticated?
            ┌─────────────┐
            │     YES     │     NO
            ↓             ↓
        Profile Complete? Login Page
        ┌─────────────┐
        │     YES     │     NO
        ↓             ↓
    Home Page    Register Update
```

### 2. **Login Flow:**

```
Login Page → Submit Credentials → LoginNotifier
                                      ↓
                                  Success?
                                ┌─────────────┐
                                │     YES     │     NO
                                ↓             ↓
                        AppAuthNotifier   Show Error
                        Set Authenticated      ↓
                                ↓         Stay Login
                            Auto Route
                                ↓
                        Profile Complete?
                        ┌─────────────┐
                        │     YES     │     NO
                        ↓             ↓
                    Home Page   Register Update
```

### 3. **Logout Flow:**

```
User Click Logout → Confirmation Dialog → AppAuthNotifier.logout()
                                               ↓
                                          Clear Session
                                               ↓
                                      Set Unauthenticated
                                               ↓
                                      Auto Route to Splash
                                               ↓
                                          Login Page
```

## 💻 **Implementation Details:**

### **AppAuthState Types:**

```dart
// State types
AppAuthInitial     // Initial state, belum check auth
AppAuthLoading     // Sedang check auth status
AppAuthAuthenticated(user)  // User authenticated
AppAuthUnauthenticated      // User not authenticated
AppAuthError(message)       // Error occurred
```

### **Key Components:**

#### 1. **AppAuthNotifier**

```dart
class AppAuthNotifier extends StateNotifier<AppAuthState> {
  // Check authentication on app startup
  Future<void> checkAuthenticationStatus()

  // Set user as authenticated (after login/register)
  void setAuthenticated(User user)

  // Logout user
  Future<void> logout()
}
```

#### 2. **SplashScreen**

```dart
class SplashScreen extends ConsumerStatefulWidget {
  // Listen to auth state changes
  // Navigate based on auth status
  // Show loading/error states
}
```

#### 3. **Updated Login/Register Notifiers**

```dart
// After successful login/register:
_ref.read(appAuthNotifierProvider.notifier).setAuthenticated(user);
```

#### 4. **Auth State Listeners**

```dart
// In login page, main screen, etc.
ref.listen<AppAuthState>(appAuthNotifierProvider, (previous, next) {
  if (next is AppAuthAuthenticated) {
    // Navigate to protected routes
  } else if (next is AppAuthUnauthenticated) {
    // Navigate to login
  }
});
```

## 🧪 **Testing Features:**

### **Logout Test Button**

- Simple floating action button untuk testing logout
- Located di main screen (akan dihapus di production)
- Confirmation dialog before logout
- Automatic navigation after logout

### **Auth State Debugging**

- Console logs di semua auth operations
- Visual loading states
- Error messages dengan retry options

## 🚀 **Usage Examples:**

### **Check Current User:**

```dart
final authState = ref.watch(appAuthNotifierProvider);
if (authState is AppAuthAuthenticated) {
  final user = authState.user;
  // Use user data
}
```

### **Manual Logout:**

```dart
await ref.read(appAuthNotifierProvider.notifier).logout();
// Navigation akan otomatis handled
```

### **Check Auth Status:**

```dart
final authNotifier = ref.read(appAuthNotifierProvider.notifier);
final isAuthenticated = authNotifier.isAuthenticated;
final isLoading = authNotifier.isLoading;
```

## 🔧 **Configuration:**

### **Initial Route:**

```dart
// app_route.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',  // Always start at splash
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // ... other routes
  ],
);
```

### **Auto Navigation Logic:**

```dart
// In SplashScreen
ref.listen<AppAuthState>(appAuthNotifierProvider, (previous, next) {
  if (next is AppAuthAuthenticated) {
    if (next.user.isProfileComplete) {
      context.go('/home');
    } else {
      context.go('/register-update');
    }
  } else if (next is AppAuthUnauthenticated) {
    context.go('/login');
  }
});
```

## 📱 **User Experience:**

### **Smooth Transitions:**

- Loading animations saat check auth
- No flickering between screens
- Consistent navigation patterns
- Error recovery options

### **Feedback:**

- Loading indicators
- Success messages
- Error messages dengan retry
- Confirmation dialogs

## 🔒 **Security Features:**

### **Token Management:**

- Automatic token validation
- Secure logout (clear session)
- Auth state persistence
- Error handling untuk expired tokens

### **Route Protection:**

- Protected routes automatically redirect ke login
- Auth status checked di app startup
- Consistent auth state across app

## 🎨 **UI States:**

### **Splash Screen States:**

- **Loading**: Circular progress + "Memuat..."
- **Error**: Error icon + message + retry button
- **Success**: Automatic navigation

### **Login Page States:**

- **Initial**: Normal form
- **Loading**: Disabled form + loading button
- **Success**: Success message + auto navigation
- **Error**: Error message + form reset

## 🚦 **Status Implementation:**

| Feature                  | Status      | Description                    |
| ------------------------ | ----------- | ------------------------------ |
| **Splash Screen**        | ✅ Complete | Auth check + navigation        |
| **App Auth Notifier**    | ✅ Complete | App-wide auth state            |
| **Login Integration**    | ✅ Complete | Auto navigation after login    |
| **Register Integration** | ✅ Complete | Auto navigation after register |
| **Logout Functionality** | ✅ Complete | Confirmation + navigation      |
| **Route Protection**     | ✅ Complete | Auth-based routing             |
| **Error Handling**       | ✅ Complete | Retry mechanisms               |
| **Loading States**       | ✅ Complete | Smooth UI transitions          |

## 🎯 **Next Steps:**

1. **Testing**:

   - Test full auth flow di device/emulator
   - Test logout dari berbagai halaman
   - Test error scenarios

2. **Cleanup**:

   - Remove logout test button
   - Remove debug logs
   - Cleanup unused imports

3. **Enhancements** (Optional):

   - Remember me functionality
   - Biometric authentication
   - Session timeout handling
   - Offline auth state

4. **Production Ready**:
   - Performance optimization
   - Error tracking integration
   - Analytics tracking
   - Security audit

## 🏁 **Conclusion:**

Authentication state management telah berhasil diimplementasikan dengan:

- ✅ Automatic routing berdasarkan auth status
- ✅ Smooth user experience
- ✅ Proper error handling
- ✅ Clean architecture patterns
- ✅ Easy testing dan debugging

User sekarang akan otomatis diarahkan ke halaman yang sesuai berdasarkan status authentication mereka, dengan feedback UI yang jelas dan handling error yang proper!
