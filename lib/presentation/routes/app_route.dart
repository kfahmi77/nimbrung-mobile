import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/features/daily-readings/presentation/screens/resension_detail_page.dart';
import 'package:nimbrung_mobile/presentation/screens/homepage/discussion_room_page.dart';
import 'package:nimbrung_mobile/presentation/screens/splash/splash_screen.dart';

import '../screens/library/library_page.dart';
import '../screens/homepage/home_page.dart';
import '../screens/login/login_page.dart';
import '../screens/main_screen.dart';
import '../screens/profile/profile_page.dart';
import '../screens/register/register_page.dart';
import '../screens/register_update/register_update_page.dart';
import '../screens/search/search_page.dart';
import '../screens/chat/chat_list_page.dart';
import '../screens/chat/chat_page.dart';
import '../screens/settings/settings_page.dart';
import 'route_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routerNeglect: false,
  routes: [
    // Splash screen - initial route
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // Login page
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/register-update',
      name: RouteNames.registerUpdate,
      builder: (context, state) => const RegisterUpdatePage(),
    ),

    // StatefulShellRoute for bottom navigation with nested routes
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Home branch with nested routes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (context, state) {
                if (kDebugMode) {
                  print('Building HomePage');
                  print('Current location: ${state.uri}');
                }
                return const HomePage();
              },
              routes: [
                // Nested route for discussion room
                GoRoute(
                  path: 'discussion',
                  name: RouteNames.discussionRoom,
                  builder: (context, state) {
                    if (kDebugMode) {
                      print('Navigating to discussion room from home');
                      print('Current location: ${state.uri}');
                    }
                    return const DiscussionPage();
                  },
                ),
                // Nested route for detail reading
                GoRoute(
                  path: 'detail-reading/:reviewId',
                  name: RouteNames.detailReading,
                  builder: (context, state) {
                    final reviewId = state.pathParameters['reviewId']!;
                    if (kDebugMode) {
                      print(
                        'Navigating to detail reading with reviewId: $reviewId',
                      );
                      print('Current location: ${state.uri}');
                    }
                    return const ReadingReviewDetailScreen();
                  },
                ),
                // Nested route for chat list
                GoRoute(
                  path: 'chat',
                  name: RouteNames.chatList,
                  builder: (context, state) {
                    if (kDebugMode) {
                      print('Navigating to chat list from home');
                      print('Current location: ${state.uri}');
                    }
                    return const ChatListPage();
                  },
                  routes: [
                    GoRoute(
                      path: ':chatId',
                      name: RouteNames.chatDetail,
                      builder: (context, state) {
                        final chatId = state.pathParameters['chatId']!;
                        final chatTitle =
                            state.uri.queryParameters['title'] ?? 'Chat';
                        final chatAvatar = state.uri.queryParameters['avatar'];
                        if (kDebugMode) {
                          print('Navigating to chat with chatId: $chatId');
                          print('Current location: ${state.uri}');
                        }
                        return ChatPage(
                          chatId: chatId,
                          chatTitle: chatTitle,
                          chatAvatar: chatAvatar,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Search branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: RouteNames.search,
              builder: (context, state) => const SearchFriendsPage(),
            ),
          ],
        ),
        // Library branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              name: RouteNames.library,
              builder: (context, state) => const LibraryPage(),
            ),
          ],
        ),
        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: RouteNames.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // Standalone routes (fullscreen, tanpa bottom navigation)
    GoRoute(
      path: '/standalone-discussion',
      name: 'standalone-discussion',
      builder: (context, state) {
        if (kDebugMode) {
          print('Navigating to standalone discussion room');
          print('Current location: ${state.uri}');
        }
        return const DiscussionPage();
      },
    ),
    GoRoute(
      path: '/standalone-detail/:reviewId',
      name: 'standalone-detail',
      builder: (context, state) {
        final reviewId = state.pathParameters['reviewId']!;
        if (kDebugMode) {
          print(
            'Navigating to standalone detail reading with reviewId: $reviewId',
          );
          print('Current location: ${state.uri}');
        }
        return const ReadingReviewDetailScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      name: RouteNames.settings,
      builder: (context, state) {
        if (kDebugMode) {
          print('Navigating to settings');
          print('Current location: ${state.uri}');
        }
        return const SettingsPage();
      },
    ),
  ],
);
