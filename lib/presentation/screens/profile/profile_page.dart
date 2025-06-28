import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/routes/route_name.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/presentation/widgets/user_avatar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _scrollOffset = 0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scrollController.addListener(_scrollListener);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _scrollListener() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isScrolled = _scrollOffset > 50;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // Enhanced background with parallax effect
            _buildParallaxBackground(),

            // Main scrollable content
            _buildScrollableContent(),

            // Animated profile picture with glow effect
            _buildAnimatedProfilePicture(),

            // Animated floating settings button (moved to last for proper z-index)
            _buildFloatingSettingsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return Positioned(
      top: -(_scrollOffset * 0.001), // Parallax effect
      left: 0,
      right: 0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/version%200.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSettingsButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isScrolled ? 50 : 40,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(RouteNames.settings),
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _isScrolled
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow:
                  _isScrolled
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Icon(
              Icons.settings,
              color: _isScrolled ? Colors.black87 : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Flexible space for background
        const SliverToBoxAdapter(child: SizedBox(height: 180)),

        // Main content with animated container
        SliverToBoxAdapter(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80), // Space for profile picture
                    // Animated user info
                    _buildAnimatedUserInfo(),

                    // Animated social stats
                    _buildAnimatedSocialStats(),

                    // Animated about section
                    _buildAnimatedAboutSection(),

                    // Enhanced written works section
                    _buildEnhancedWrittenWorksSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedProfilePicture() {
    double profileTop = 100 - (_scrollOffset * 0.3);
    double profileSize = (140 - (_scrollOffset * 0.2)).clamp(0.0, 140.0);
    double opacity = (1.0 - (_scrollOffset / 150)).clamp(0.0, 1.0);
    double scale = (1.0 - (_scrollOffset / 200)).clamp(0.0, 1.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      top: profileTop,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Hero(
              tag: 'profile_picture',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: profileSize,
                height: profileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2 * opacity),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3 * opacity),
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: UserAvatar(
                    radius: profileSize / 2,
                    fallbackImageUrl:
                        'https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Image-141.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedUserInfo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Column(
                children: [
                  UserDisplayName(
                    preferUsername: false, // Prefer fullname for profile
                    fallbackText: 'Karien Zain',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  8.height,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: UserPreference(
                      fallbackPreference: 'Psikologi',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSocialStats() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem('100', 'Teman'),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  _buildStatItem('40', 'Pengikut'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        4.height,
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedAboutSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  16.height,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: UserBio(
                      fallbackBio:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sit amet urna eget tortor rutrum cursus. Curabitur a mi leo. Aenean nec efficitur lacus. Aliquam pellentesque eu orci sed efficitur. Sed sagittis pretium odio eu condimentum. Mauris eu urna eget ante mollis pharetra dignissim id lorem.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWrittenWorksSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Karya Tulis Terbaru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Add navigation logic
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lebih',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              4.width,
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  20.height,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '7 Mata Menyala',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                12.height,
                                Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sit amet urna eget tortor rutrum cursus. Curabitur a mi leo. Aenean nec efficitur lacus.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          20.width,
                          Hero(
                            tag: 'book_cover',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png',
                                  width: 85,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  48.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
