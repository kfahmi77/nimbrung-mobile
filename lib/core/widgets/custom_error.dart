import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/daily-readings/presentation/providers/resension_provider.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';

class ErrorWidgetDisplay extends ConsumerStatefulWidget {
  final Object error;

  const ErrorWidgetDisplay({super.key, required this.error});

  @override
  ConsumerState<ErrorWidgetDisplay> createState() => _ErrorWidgetDisplayState();
}

class _ErrorWidgetDisplayState extends ConsumerState<ErrorWidgetDisplay> {
  late String errorMessage;
  late String errorDetails;

  @override
  void initState() {
    super.initState();
    _processError(widget.error);
  }

  void _processError(Object error) {
    errorMessage = 'Terjadi kesalahan';
    errorDetails = '';

    if (error is Failure) {
      switch (error.runtimeType) {
        case NetworkFailure _:
          errorMessage = 'Tidak ada koneksi internet';
          errorDetails = 'Periksa koneksi internet Anda dan coba lagi.';
          break;
        case ServerFailure _:
          errorMessage = 'Server bermasalah';
          errorDetails = error.message;
          break;
        case ClientFailure _:
          errorMessage = 'Kesalahan akses';
          errorDetails = error.message;
          break;
        case UnknownFailure _:
          errorMessage = 'Kesalahan tidak diketahui';
          errorDetails = error.message;
          break;
        default:
          errorMessage = error.message;
          errorDetails = 'Kode: ${error.code}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorDetails,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AppLogger.info(
                'Refreshing reading reviews',
                tag: 'ResensionCard',
              );
              ref.invalidate(readingReviewsProvider);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
