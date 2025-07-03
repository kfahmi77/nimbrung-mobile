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
  int _readTimeSeconds = 0;
  late DateTime _startTime;
  bool _wasHelpful = true;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
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
    final todayReadingAsync = ref.watch(todayReadingProvider(userId));

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
                  16.height,
                  ElevatedButton(
                    onPressed: () => ref.refresh(todayReadingProvider(userId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (reading) {
          if (reading == null) {
            return const Center(child: Text('Reading not found'));
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
    if (reading.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            12.width,
            const Expanded(
              child: Text(
                'Selamat! Anda telah menyelesaikan bacaan ini.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            'Selesaikan Bacaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          16.height,
          const Text(
            'Apakah bacaan ini membantu Anda?',
            style: TextStyle(fontSize: 14),
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _wasHelpful,
                      onChanged:
                          (value) => setState(() => _wasHelpful = value!),
                    ),
                    const Text('Ya, sangat membantu'),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _wasHelpful,
                      onChanged:
                          (value) => setState(() => _wasHelpful = value!),
                    ),
                    const Text('Kurang membantu'),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              hintText: 'Tulis catatan atau refleksi Anda...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          24.height,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeReading(reading, userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tandai Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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

  void _completeReading(DailyReading reading, String userId) {
    final endTime = DateTime.now();
    _readTimeSeconds = endTime.difference(_startTime).inSeconds;

    ref
        .read(readingCompletionProvider.notifier)
        .completeReading(
          userId: userId,
          readingId: reading.id,
          readTimeSeconds: _readTimeSeconds,
          wasHelpful: _wasHelpful,
          userNote:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
        );

    // Listen to completion result
    ref.listen(readingCompletionProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selamat! Bacaan telah diselesaikan.'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the reading data
            ref.invalidate(todayReadingProvider(userId));
          }
        },
        error: (error, stackTrace) {
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
