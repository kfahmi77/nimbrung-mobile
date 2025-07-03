import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/extension/spacing_extension.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../presentation/themes/color_schemes.dart';
import '../../../auth/presentation/notifiers/app_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/daily_reading_providers.dart';

class DailyReadingCard extends ConsumerWidget {
  const DailyReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    if (authState is! AppAuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final userId = authState.user.id;
    final todayReadingAsync = ref.watch(todayReadingProvider(userId));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: todayReadingAsync.when(
        loading: () => const _LoadingContent(),
        error: (error, stackTrace) {
          AppLogger.error(
            'Error loading today reading',
            tag: 'DailyReadingCard',
            error: error,
            stackTrace: stackTrace,
          );
          return _ErrorContent(error: error.toString());
        },
        data: (reading) {
          if (reading == null) {
            return const _NoReadingContent();
          }
          return _ReadingContent(reading: reading, userId: userId);
        },
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        16.height,
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        8.height,
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String error;

  const _ErrorContent({required this.error});

  @override
  Widget build(BuildContext context) {
    // Check if this is a schema initialization error
    final isSchemaError = error.contains('Database schema not initialized');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSchemaError ? 'Setup Diperlukan' : 'Ups! Ada Kendala',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.height,
        Text(
          isSchemaError
              ? 'Database belum diinisialisasi. Silakan terapkan schema SQL terlebih dahulu.'
              : 'Tidak dapat memuat bacaan hari ini. Silakan coba lagi nanti.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        if (isSchemaError) ...[
          16.height,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Text(
              'Langkah setup:\n1. Buka Supabase Dashboard\n2. Jalankan sql/daily_reading_schema.sql\n3. Jalankan sql/daily_reading_dummy_data.sql',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoReadingContent extends StatelessWidget {
  const _NoReadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Belum Ada Bacaan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.height,
        Text(
          'Belum ada bacaan tersedia untuk hari ini. Silakan periksa preferensi Anda atau hubungi admin.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }
}

class _ReadingContent extends ConsumerWidget {
  final dynamic reading;
  final String userId;

  const _ReadingContent({required this.reading, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Truncate content for preview
    final previewContent =
        reading.content.length > 150
            ? '${reading.content.substring(0, 150)}...'
            : reading.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reading info
        if (reading.subjectName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reading.subjectName!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          12.height,
        ],

        // Title
        Text(
          reading.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        12.height,

        // Content preview
        Text(
          previewContent,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),

        // Reading time
        if (reading.readTimeMinutes > 0) ...[
          12.height,
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              4.width,
              Text(
                '${reading.readTimeMinutes} menit baca',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],

        24.height,

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _navigateToReadingDetail(context, reading),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Baca Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            12.width,
            if (reading.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              ),
            ] else ...[
              IconButton(
                onPressed:
                    () => _showQuickActions(context, ref, reading, userId),
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _navigateToReadingDetail(BuildContext context, reading) {
    // Navigate to reading detail page using the nested route
    context.go('/home/daily-reading/${reading.id}');
  }

  void _showQuickActions(
    BuildContext context,
    WidgetRef ref,
    reading,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                16.height,

                Text(
                  'Aksi Cepat',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                16.height,

                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: const Text('Baca Lengkap'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToReadingDetail(context, reading);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Tandai Selesai'),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsComplete(ref, reading, userId);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Lihat Riwayat'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/daily-reading/history');
                  },
                ),

                16.height,
              ],
            ),
          ),
    );
  }

  void _markAsComplete(WidgetRef ref, reading, String userId) {
    ref
        .read(readingCompletionProvider.notifier)
        .completeReading(
          userId: userId,
          readingId: reading.id,
          wasHelpful: true,
        );
  }
}
