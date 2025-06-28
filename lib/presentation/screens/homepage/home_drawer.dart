import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/features/auth/presentation/providers/auth_providers.dart';

import '../../themes/color_schemes.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({super.key});

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Simple slide animation for all items
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Start animation when drawer opens with a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              children: [
                // Header with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                            ),
                          ),
                        ),
                        16.height,
                        Text(
                          'Nimbrung User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'user@nimbrung.com',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Menu Items with staggered animations
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildAnimatedMenuItem(0, 'assets/images/home.svg', 'Beranda', () {
                        Navigator.pop(context);
                        context.go('/home');
                      }),
                      _buildAnimatedMenuItem(1, 'assets/images/book.svg', 'Perpustakaan', () {
                        Navigator.pop(context);
                        context.go('/library');
                      }),
                      _buildAnimatedMenuItem(2, 'assets/images/search.svg', 'Pencarian', () {
                        Navigator.pop(context);
                        context.go('/search');
                      }),
                      _buildAnimatedMenuItem(3, 'assets/images/chat.svg', 'Pesan', () {
                        Navigator.pop(context);
                        context.go('/home/chat');
                      }),
                      _buildAnimatedMenuItem(4, 'assets/images/user.svg', 'Profile', () {
                        Navigator.pop(context);
                        context.go('/profile');
                      }),
                      _buildAnimatedMenuItem(5, 'assets/images/security.svg', 'Pengaturan', () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pengaturan akan segera tersedia')),
                        );
                      }),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Divider(color: Colors.grey[300], height: 32),
                      ),
                      
                      _buildAnimatedMenuItem(6, 'assets/images/share.svg', 'Bagikan Aplikasi', () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fitur bagikan akan segera tersedia')),
                        );
                      }),
                      _buildAnimatedMenuItem(7, Icons.help_outline, 'Bantuan', () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Halaman bantuan akan segera tersedia')),
                        );
                      }),
                    ],
                  ),
                ),
                
                // Logout Button with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: AppColors.danger,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Keluar',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem(
    int index,
    dynamic icon,
    String title,
    VoidCallback onTap,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildMenuItem(
          icon: icon,
          title: title,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon is String
              ? SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: AppColors.primary.withOpacity(0.05),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar'),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close drawer
                ref.read(appAuthNotifierProvider.notifier).logout();
              },
              child: Text(
                'Keluar',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }
}
