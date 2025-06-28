import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/visibility_provider.dart';
import '../providers/drawer_provider.dart';
import '../themes/color_schemes.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/notifiers/app_auth_notifier.dart';

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(bottomNavVisibilityProvider);
    final isDrawerOpen = ref.watch(drawerStateProvider);

    // Listen to auth state for logout navigation
    ref.listen<AppAuthState>(appAuthNotifierProvider, (previous, next) {
      if (next is AppAuthUnauthenticated) {
        // User logged out, navigate to splash/login
        context.go('/');
      }
    });

    // Check if current location is a nested route that should hide bottom nav
    final currentLocation = GoRouterState.of(context).uri.toString();
    final shouldHideBottomNav = _shouldHideBottomNavigation(currentLocation);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset:
            (isVisible && !shouldHideBottomNav && !isDrawerOpen)
                ? Offset.zero
                : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity:
              (isVisible && !shouldHideBottomNav && !isDrawerOpen) ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24, right: 58, left: 58),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    index: 0,
                    selectedIndex: navigationShell.currentIndex,
                    onTap: () => _onTap(navigationShell, 0),
                  ),
                  _NavItem(
                    icon: Icons.search,
                    index: 1,
                    selectedIndex: navigationShell.currentIndex,
                    onTap: () => _onTap(navigationShell, 1),
                  ),
                  _NavItem(
                    icon: Icons.menu_book,
                    index: 2,
                    selectedIndex: navigationShell.currentIndex,
                    onTap: () => _onTap(navigationShell, 2),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    index: 3,
                    selectedIndex: navigationShell.currentIndex,
                    onTap: () => _onTap(navigationShell, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldHideBottomNavigation(String location) {
    // Hide bottom navigation for nested routes
    return location.contains('/home/discussion') ||
        location.contains('/home/detail-reading') ||
        location.contains('/home/chat') ||
        location.contains('/standalone-');
  }

  void _onTap(StatefulNavigationShell shell, int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white54,
        size: 28,
      ),
    );
  }
}
