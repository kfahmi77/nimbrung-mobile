import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/extension/spacing_extension.dart';
import '../../../../../presentation/themes/color_schemes.dart';
import '../../../auth/presentation/notifiers/app_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../discussions/presentation/widgets/join_discussion_button.dart'
    show ComingSoonDiscussionButton;
import '../../domain/entities/daily_reading.dart';
import '../providers/daily_reading_providers.dart';
import '../widgets/reading_testing_widget.dart';

class DailyReadingDetailScreen extends ConsumerStatefulWidget {
  final String readingId;

  const DailyReadingDetailScreen({super.key, required this.readingId});

  @override
  ConsumerState<DailyReadingDetailScreen> createState() =>
      _DailyReadingDetailScreenState();
}

class _DailyReadingDetailScreenState
    extends ConsumerState<DailyReadingDetailScreen> {
  bool _isReadingMode = false;
  double _fontSize = 16.0;
  bool? _userFeedback; // null = no feedback, true = helpful, false = not helpful
  String? _currentReadingId; // Track current reading ID to reset feedback on new reading

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthNotifierProvider);

    if (authState is! AppAuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    final userId = authState.user.id;

    // For now, let's get today's reading and find the specific one
    final todayReadingAsync = ref.watch(autoRefreshTodayReadingProvider(userId));

    return Scaffold(
      backgroundColor: _isReadingMode ? Colors.white : Colors.grey[50],
      appBar: _isReadingMode ? null : _buildAppBar(),
      body: todayReadingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  16.height,
                  Text('Error: $error'),
                  16.height,                    ElevatedButton(
                      onPressed: () => ref.refresh(autoRefreshTodayReadingProvider(userId)),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ),
        data: (reading) {
          if (reading == null) {
            return const Center(child: Text('Reading not found'));
          }
          
          // Reset feedback state if this is a new reading
          if (_currentReadingId != reading.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentReadingId = reading.id;
                _userFeedback = null;
              });
            });
          }
          
          return _buildContent(reading, userId);
        },
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Bacaan Harian',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chrome_reader_mode, color: Colors.black87),
          onPressed: _toggleReadingMode,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black87),
          onPressed: _shareReading,
        ),
      ],
    );
  }

  Widget _buildContent(DailyReading reading, String userId) {
    if (_isReadingMode) {
      return _buildReadingModeContent(reading);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReadingTestingWidget(userId: userId),
          _buildReadingHeader(reading),
          24.height,
          _buildReadingContent(reading),
          24.height,
          if (reading.keyInsight != null) _buildKeyInsight(reading.keyInsight!),
          if (reading.tomorrowHint != null) ...[
            24.height,
            _buildTomorrowHint(reading.tomorrowHint!),
          ],
          24.height,
          _buildActionButtons(reading, userId),
          24.height,
          _buildDiscussionSection(reading),
          48.height,
        ],
      ),
    );
  }

  Widget _buildReadingModeContent(DailyReading reading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleReadingMode,
                ),
                const Expanded(
                  child: Text(
                    'Mode Membaca',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildFontControls(),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.title,
                  style: TextStyle(
                    fontSize: _fontSize + 4,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                24.height,
                Text(
                  reading.content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontControls() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.text_decrease, size: 20),
          onPressed: _decreaseFontSize,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_fontSize.toInt()}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase, size: 20),
          onPressed: _increaseFontSize,
        ),
      ],
    );
  }

  Widget _buildReadingHeader(DailyReading reading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reading.subjectName ?? 'Bacaan Harian',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Hari ${reading.daySequence}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          16.height,
          Text(
            reading.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          12.height,
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              4.width,
              Text(
                '${reading.readTimeMinutes} menit baca',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              16.width,
              if (reading.isCompleted) ...[
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                4.width,
                const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent(DailyReading reading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        reading.content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildKeyInsight(String keyInsight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
              8.width,
              Text(
                'Key Insight',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          12.height,
          Text(
            keyInsight,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowHint(String tomorrowHint) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Colors.blue[700], size: 20),
              8.width,
              Text(
                'Besok Kita Bahas',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          12.height,
          Text(
            tomorrowHint,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DailyReading reading, String userId) {
    // Show feedback given state if user has provided feedback
    if (_userFeedback != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _userFeedback! ? Colors.green[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _userFeedback! ? Colors.green[200]! : Colors.orange[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _userFeedback! ? Icons.thumb_up : Icons.thumb_down,
              color: _userFeedback! ? Colors.green[700] : Colors.orange[700],
            ),
            12.width,
            Expanded(
              child: Text(
                _userFeedback!
                    ? 'Terima kasih! Feedback Anda membantu kami.'
                    : 'Terima kasih atas feedback Anda. Kami akan terus perbaiki.',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apakah bacaan ini membantu?',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
          8.height,
          const Text(
            'Berikan feedback Anda dengan sekali tap',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          20.height,
          Row(
            children: [
              Expanded(
                child: _buildThumbButton(
                  icon: Icons.thumb_up,
                  label: 'Membantu',
                  color: Colors.green,
                  isHelpful: true,
                  onPressed: () => _quickReaction(reading, userId, true),
                ),
              ),
              16.width,
              Expanded(
                child: _buildThumbButton(
                  icon: Icons.thumb_down,
                  label: 'Kurang',
                  color: Colors.red,
                  isHelpful: false,
                  onPressed: () => _quickReaction(reading, userId, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isHelpful,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                12.height,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "reading_mode",
          mini: true,
          onPressed: _toggleReadingMode,
          backgroundColor: AppColors.primary,
          child: Icon(
            _isReadingMode ? Icons.close : Icons.chrome_reader_mode,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _toggleReadingMode() {
    setState(() {
      _isReadingMode = !_isReadingMode;
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 24.0) _fontSize += 1.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 1.0;
    });
  }

  void _shareReading() {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Berbagi bacaan...')));
  }

  void _quickReaction(DailyReading reading, String userId, bool isHelpful) {
    // Set local feedback state immediately
    setState(() {
      _userFeedback = isHelpful;
    });

    ref
        .read(readingCompletionProvider.notifier)
        .recordFeedback(
          userId: userId,
          readingId: reading.id,
          isHelpful: isHelpful,
        );

    // Listen to completion result
    ref.listen(readingCompletionProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isHelpful 
                    ? 'Feedback berhasil disimpan!' 
                    : 'Feedback berhasil disimpan!',
                ),
                backgroundColor: isHelpful ? Colors.green : Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            // Don't refresh the provider to keep reading visible
          }
        },
        error: (error, stackTrace) {
          // Reset feedback state on error
          setState(() {
            _userFeedback = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
  }

  Widget _buildDiscussionSection(DailyReading reading) {
    return ComingSoonDiscussionButton(readingTitle: reading.title);
  }
}

