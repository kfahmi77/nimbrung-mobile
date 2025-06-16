import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../themes/color_schemes.dart';

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
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
    );
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
