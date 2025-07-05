import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/utils/extension/spacing_extension.dart';
import '../../../../presentation/themes/color_schemes.dart';
import '../providers/daily_reading_provider.dart';
import '../../../../../core/utils/logger.dart';

class DailyReadingCard extends ConsumerStatefulWidget {
  const DailyReadingCard({super.key});

  @override
  ConsumerState<DailyReadingCard> createState() => _DailyReadingCardState();
}

class _DailyReadingCardState extends ConsumerState<DailyReadingCard> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'Widget: Initializing DailyReadingCard',
      tag: 'DailyReadingCard',
    );
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      AppLogger.info(
        'Widget: Current user found: ${user.id}',
        tag: 'DailyReadingCard',
      );
      setState(() {
        _currentUserId = user.id;
      });
      // Load daily reading for current user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLogger.info(
          'Widget: Loading daily reading for user',
          tag: 'DailyReadingCard',
        );
        ref.read(dailyReadingProvider.notifier).getDailyReading(user.id);
      });
    } else {
      AppLogger.warning(
        'Widget: No current user found',
        tag: 'DailyReadingCard',
      );
    }
  }

  void _handleFeedback(String feedbackType) {
    if (_currentUserId == null) {
      AppLogger.warning(
        'Widget: Cannot handle feedback - no current user',
        tag: 'DailyReadingCard',
      );
      return;
    }

    final reading = ref.read(dailyReadingProvider).value;
    if (reading == null) {
      AppLogger.warning(
        'Widget: Cannot handle feedback - no current reading',
        tag: 'DailyReadingCard',
      );
      return;
    }

    AppLogger.info(
      'Widget: Handling feedback: $feedbackType for reading: ${reading.id}',
      tag: 'DailyReadingCard',
    );

    ref
        .read(dailyReadingProvider.notifier)
        .submitFeedback(_currentUserId!, reading.id, feedbackType);
  }

  void _handleDiscussion() {
    if (_currentUserId == null) {
      AppLogger.warning(
        'Widget: Cannot handle discussion - no current user',
        tag: 'DailyReadingCard',
      );
      return;
    }

    final reading = ref.read(dailyReadingProvider).value;
    if (reading == null) {
      AppLogger.warning(
        'Widget: Cannot handle discussion - no current reading',
        tag: 'DailyReadingCard',
      );
      return;
    }

    AppLogger.info(
      'Widget: Handling discussion for reading: ${reading.id}',
      tag: 'DailyReadingCard',
    );

    // Mark as read when user goes to discussion
    ref
        .read(dailyReadingProvider.notifier)
        .markAsRead(_currentUserId!, reading.id);

    // Navigate to discussion
    AppLogger.info(
      'Widget: Navigating to discussion page',
      tag: 'DailyReadingCard',
    );
    context.go('/home/discussion');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Widget: Building DailyReadingCard, currentUserId: $_currentUserId',
      tag: 'DailyReadingCard',
    );

    if (_currentUserId == null) {
      AppLogger.info(
        'Widget: Showing login prompt - no authenticated user',
        tag: 'DailyReadingCard',
      );
      return _buildLoginPrompt();
    }

    final dailyReadingState = ref.watch(dailyReadingProvider);

    return dailyReadingState.when(
      loading: () {
        AppLogger.debug(
          'Widget: Showing loading state',
          tag: 'DailyReadingCard',
        );
        return _buildLoadingCard();
      },
      error: (error, stack) {
        AppLogger.error(
          'Widget: Showing error state',
          tag: 'DailyReadingCard',
          error: error,
        );
        return _buildErrorCard(error.toString());
      },
      data: (reading) {
        if (reading == null) {
          AppLogger.info(
            'Widget: Showing no reading card - no data available',
            tag: 'DailyReadingCard',
          );
          return _buildNoReadingCard();
        }
        AppLogger.debug(
          'Widget: Showing reading card for: ${reading.id}, scope: ${reading.scopeName}',
          tag: 'DailyReadingCard',
        );
        return _buildReadingCard(reading);
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Silakan login untuk mendapatkan bacaan harian yang dipersonalisasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          16.height,
          Text(
            'Memuat bacaan harian...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gagal memuat bacaan harian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.height,
          Text(
            error,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          16.height,
          ElevatedButton(
            onPressed: () {
              if (_currentUserId != null) {
                AppLogger.info(
                  'Widget: Retry button pressed, reloading daily reading',
                  tag: 'DailyReadingCard',
                );
                ref
                    .read(dailyReadingProvider.notifier)
                    .getDailyReading(_currentUserId!);
              }
            },
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum ada bacaan harian tersedia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.height,
          Text(
            'Silakan periksa kembali nanti',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(reading) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reading content
          Text(
            reading.content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          if (reading.quote != null) ...[
            16.height,
            Text(
              '"${reading.quote}"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],

          16.height,

          // Scope info
          Text(
            'Ruang Lingkup: ${reading.scopeName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          24.height,

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _handleDiscussion,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Diskusikan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              16.width,
              GestureDetector(
                onTap: () => _handleFeedback('up'),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        reading.userFeedback == 'up'
                            ? AppColors.primary
                            : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.thumb_up_alt_outlined,
                    color:
                        reading.userFeedback == 'up'
                            ? Colors.white
                            : AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              8.width,
              GestureDetector(
                onTap: () => _handleFeedback('down'),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        reading.userFeedback == 'down'
                            ? AppColors.primary
                            : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.thumb_down_off_alt_rounded,
                    color:
                        reading.userFeedback == 'down'
                            ? Colors.white
                            : AppColors.primary,
                    size: 22,
                  ),
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
    );
  }
}
