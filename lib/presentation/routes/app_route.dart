import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/features/daily-readings/presentation/screens/resension_detail_page.dart';
import 'package:nimbrung_mobile/presentation/screens/homepage/discussion_room_page.dart';

import '../screens/favorite/favorite_page.dart';
import '../screens/homepage/home_page.dart';
import '../screens/login/login_page.dart';
import '../screens/main_screen.dart';
import '../screens/profile/profile_page.dart';
import '../screens/register/register_page.dart';
import '../screens/register_update/register_update_page.dart';
import '../screens/search/search_page.dart';
import 'route_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Selalu enable untuk debugging
  // Tambahkan ini untuk memaksa URL sync
  routerNeglect: false,
  routes: [
    GoRoute(
      path: '/',
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

    // Routes yang ingin tampil fullscreen (tanpa bottom navigation)
    GoRoute(
      path: '/detail-reading/:reviewId',
      name: RouteNames.detailReading,
      builder: (context, state) {
        final reviewId = state.pathParameters['reviewId']!;
        // Debug print
        if (kDebugMode) {
          print('Navigating to detail reading with reviewId: $reviewId');
          print('Current location: ${state.uri}');
        }
        return const ReadingReviewDetailScreen();
      },
    ),
    GoRoute(
      path: '/discussion-room',
      name: RouteNames.discussionRoom,
      builder: (context, state) {
        // Debug print
        if (kDebugMode) {
          print('Navigating to discussion room');
          print('Current location: ${state.uri}');
        }
        return const DiscussionPage();
      },
    ),

    // StatefulShellRoute for bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: RouteNames.search,
              builder: (context, state) => const SearchFriendsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorite',
              name: RouteNames.favorite,
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
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
  ],
);
