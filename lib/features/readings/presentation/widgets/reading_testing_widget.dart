import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/extension/spacing_extension.dart';
import '../providers/daily_reading_providers.dart';

class ReadingTestingWidget extends ConsumerWidget {
  final String userId;

  const ReadingTestingWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.orange[700], size: 20),
              8.width,
              Text(
                'Testing Mode',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          12.height,
          Text(
            'Test pergantian bacaan harian tanpa menunggu 24 jam',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[800],
            ),
          ),
          16.height,
          // Reading Info Display
          Consumer(
            builder: (context, ref, child) {
              final readingInfoAsync = ref.watch(readingInfoProvider(userId));
              
              return readingInfoAsync.when(
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Testing Functions Missing',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                      4.height,
                      const Text(
                        'Please apply sql/testing_functions.sql to your Supabase database to enable testing features.',
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                      if (error.toString().contains('PGRST202')) ...[
                        4.height,
                        const Text(
                          'Functions not found in database schema.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                data: (info) => info != null ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject: ${info['subject_name'] ?? 'Unknown'}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      4.height,
                      Text(
                        'Current Day: ${info['current_day']} / ${info['max_day']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (info['has_next_day'] == false) ...[
                        4.height,
                        Text(
                          '⚠️ Sudah mencapai bacaan terakhir',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ) : const SizedBox(),
              );
            },
          ),
          16.height,
          // Testing Buttons
          Consumer(
            builder: (context, ref, child) {
              final testingState = ref.watch(readingTestingProvider);
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: testingState.isLoading ? null : () {
                            ref.read(readingTestingProvider.notifier).simulateDayChange(
                              userId: userId,
                              daysToAdvance: 1,
                            );
                            // Refresh reading info
                            ref.invalidate(readingInfoProvider(userId));
                          },
                          icon: const Icon(Icons.skip_next, size: 16),
                          label: const Text(
                            'Next Day',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: testingState.isLoading ? null : () {
                            ref.read(readingTestingProvider.notifier).resetToDay1(userId);
                            // Refresh reading info
                            ref.invalidate(readingInfoProvider(userId));
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text(
                            'Reset to Day 1',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (testingState.isLoading) ...[
                    8.height,
                    const LinearProgressIndicator(),
                  ],
                  if (testingState.hasError) ...[
                    8.height,
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '❌ Action Failed',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          4.height,
                          if (testingState.error.toString().contains('PGRST202') ||
                              testingState.error.toString().contains('function') ||
                              testingState.error.toString().contains('does not exist')) ...[
                            const Text(
                              'Testing functions missing from database.',
                              style: TextStyle(fontSize: 11, color: Colors.red),
                            ),
                            2.height,
                            const Text(
                              'Apply sql/testing_functions.sql to Supabase.',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ] else ...[
                            Text(
                              testingState.error.toString(),
                              style: const TextStyle(fontSize: 11, color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (testingState.hasValue && testingState.value != null) ...[
                    8.height,
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        testingState.value!['message'] ?? 'Success',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
