import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../themes/color_schemes.dart';
import '../../providers/drawer_provider.dart';
import 'appbar.dart';
import '../../../features/daily-readings/presentation/screens/widgets/resension.dart';
import '../../widgets/chat_bot_avatar.dart';
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
                        color: Colors.black.withOpacity(
                          0.2 * _drawerAnimationController.value,
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
                    child: SingleChildScrollView(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //user appbar
                                  AppbarWidget(),
                                  24.height,
                                  // Greeting
                                  Text(
                                    'Yuk, Baca Dulu!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Card container
                                  Container(
                                    margin: EdgeInsets.only(top: 16),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Main content
                                        Text(
                                          'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran,',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                        ),
                                        8.height,
                                        Text(
                                          'dan pengambilan keputusan.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                        ),
                                        16.height,

                                        // Source
                                        Text(
                                          'Solso, R. L. (2008). Cognitive Psychology: Edisi Kedelapan. Erlangga.',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        24.height,

                                        // Action buttons
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navigate to nested discussion route
                                                  context.go(
                                                    '/home/discussion',
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Diskusikan',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            16.width,
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.thumb_up_alt_outlined,
                                                color: AppColors.primary,
                                                size: 22,
                                              ),
                                            ),
                                            8.width,
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .thumb_down_off_alt_rounded,
                                                color: AppColors.primary,
                                                size: 22,
                                              ),
                                            ),
                                            8.width,
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: SvgPicture.asset(
                                                'assets/images/share.svg',
                                                width: 22,
                                                height: 22,
                                              ),
                                            ),
                                            8.width,
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Book Resension Section
                          ResensionCard(),
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
