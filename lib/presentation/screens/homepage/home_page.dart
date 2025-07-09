import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/extension/snackbar_extension.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../themes/color_schemes.dart';
import '../../providers/drawer_provider.dart';
import 'appbar.dart';
import '../../../features/daily-readings/presentation/screens/widgets/resension.dart';
import '../../../features/daily_reading/presentation/widgets/daily_reading_card.dart';
import '../../../features/daily_reading/presentation/providers/daily_reading_provider.dart';
import '../../widgets/chat_bot_avatar.dart';
import '../../widgets/custom_refresh_indicator.dart';
import './home_drawer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _borderRadiusAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    try {
      // Add haptic feedback for better UX
      HapticFeedback.mediumImpact();

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Refresh daily reading data
        await ref.read(dailyReadingProvider.notifier).getDailyReading(user.id);

        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        // if (mounted) {
        //   context.showCustomSnackbar(
        //     message: 'Data berhasil diperbarui!',
        //     type: SnackbarType.success,
        //   );
        // }
      }
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();
      if (mounted) {
        context.showCustomSnackbar(
          message: 'Gagal memperbarui data: ${e.toString()}',
          type: SnackbarType.error,
          onTap: () => _handleRefresh(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to drawer state changes
    ref.listen<bool>(drawerStateProvider, (previous, next) {
      if (next) {
        _drawerAnimationController.forward();
      } else {
        _drawerAnimationController.reverse();
      }
    });

    return Scaffold(
      drawer: const HomeDrawer(),
      onDrawerChanged: (isOpened) {
        // Update drawer state in provider
        ref.read(drawerStateProvider.notifier).state = isOpened;
      },
      body: AnimatedBuilder(
        animation: _drawerAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (_drawerAnimationController.value > 0)
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.2 * _drawerAnimationController.value,
                        ),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Theme.of(context).primaryColor,
                  ),
                  child: SafeArea(
                    child: EnhancedRefreshIndicator(
                      primaryColor: Color(0xFFE17B47),
                      secondaryColor: Color(0xFFFF9A56),
                      backgroundColor: Colors.white,
                      style: RefreshStyle.pulse,
                      onRefresh: _handleRefresh,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //user appbar
                                        AppbarWidget(),
                                        24.height,
                                        // Greeting with refresh hint
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Yuk, Baca Dulu!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        16.height,
                                        // Dynamic Daily Reading Card
                                        DailyReadingCard(),
                                      ],
                                    ),
                                  ),
                                ),

                                // Book Resension Section
                                ResensionCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _drawerAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: ChatBotAvatar(),
            ),
          );
        },
      ),
    );
  }
}
