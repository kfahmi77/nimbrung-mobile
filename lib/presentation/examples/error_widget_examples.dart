import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../widgets/custom_error.dart';
import '../widgets/error_helpers.dart';

/// Example usage of the improved CustomErrorWidget with loading states
class ErrorWidgetExamples extends StatelessWidget {
  const ErrorWidgetExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Widget Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Basic Error with Loading on Retry',
              CustomErrorWidget(
                error: const NetworkFailure(),
                showLoadingOnRetry: true,
                onRetry: () async {
                  // Simulate API call
                  await Future.delayed(const Duration(seconds: 2));
                },
              ),
            ),
            _buildSection(
              'Provider Error (Auto Loading)',
              // This widget automatically shows loading when retrying
              CustomErrorWidgetWithProvider(
                error: const ServerFailure(
                  message: 'Server tidak dapat dijangkau',
                  code: 'SERVER_ERROR',
                ),
                provider: demoProvider, // Replace with your actual provider
                customMessage: 'Gagal memuat data',
                customDetails: 'Server sedang mengalami gangguan.',
              ),
            ),
            _buildSection(
              'Network Error with Helper',
              ErrorHelpers.networkError(
                onRetry: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                showLoadingOnRetry: true,
              ),
            ),
            _buildSection(
              'Error with Extension',
              const UnknownFailure().toErrorWidget(
                onRetry: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                showLoadingOnRetry: true,
                customMessage: 'Ups, ada yang salah!',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget widget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Demo provider for example
final demoProvider = Provider<String>((ref) => 'Demo data');

/// Usage in your actual pages:
/// 
/// ```dart
/// AsyncValue<List<Data>> asyncData = ref.watch(yourProvider);
/// 
/// return asyncData.when(
///   loading: () => const Center(child: CircularProgressIndicator()),
///   error: (error, stackTrace) {
///     return CustomErrorWidgetWithProvider(
///       error: error,
///       provider: yourProvider,
///       logTag: 'YourPage',
///       customMessage: 'Gagal memuat data',
///       // Loading akan otomatis ditampilkan saat retry
///     );
///   },
///   data: (data) => YourDataWidget(data: data),
/// );
/// ```
