import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';

class CustomErrorWidget extends StatefulWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final String? customDetails;
  final IconData? customIcon;
  final Color? iconColor;
  final String? retryButtonText;
  final bool showRetryButton;
  final EdgeInsets? padding;
  final MainAxisAlignment? alignment;
  final bool showLoadingOnRetry;
  final Duration? loadingDuration;
  final String? loadingMessage;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
    this.customDetails,
    this.customIcon,
    this.iconColor,
    this.retryButtonText,
    this.showRetryButton = true,
    this.padding,
    this.alignment,
    this.showLoadingOnRetry = false,
    this.loadingDuration = const Duration(milliseconds: 500),
    this.loadingMessage,
  });

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget> {
  late String errorMessage;
  late String errorDetails;
  late IconData errorIcon;
  late Color errorIconColor;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _processError();
  }

  void _processError() {
    // Set defaults
    errorMessage = widget.customMessage ?? 'Terjadi kesalahan';
    errorDetails = widget.customDetails ?? '';
    errorIcon = widget.customIcon ?? Icons.error_outline;
    errorIconColor = widget.iconColor ?? Colors.red[400]!;

    // Process error if no custom message provided
    if (widget.customMessage == null && widget.error is Failure) {
      final failure = widget.error as Failure;
      switch (failure.runtimeType) {
        case NetworkFailure _:
          errorMessage = 'Tidak ada koneksi internet';
          errorDetails =
              widget.customDetails ??
              'Periksa koneksi internet Anda dan coba lagi.';
          errorIcon = widget.customIcon ?? Icons.wifi_off;
          errorIconColor = widget.iconColor ?? Colors.orange[400]!;
          break;
        case ServerFailure _:
          errorMessage = 'Server bermasalah';
          errorDetails = widget.customDetails ?? failure.message;
          errorIcon = widget.customIcon ?? Icons.dns_outlined;
          break;
        case ClientFailure _:
          errorMessage = 'Kesalahan akses';
          errorDetails = widget.customDetails ?? failure.message;
          errorIcon = widget.customIcon ?? Icons.lock_outline;
          break;
        case UnknownFailure _:
          errorMessage = 'Kesalahan tidak diketahui';
          errorDetails = widget.customDetails ?? failure.message;
          break;
        default:
          errorMessage = failure.message;
          errorDetails = widget.customDetails ?? 'Kode: ${failure.code}';
      }
    }

    // Fallback for non-Failure errors
    if (widget.customMessage == null && widget.error is! Failure) {
      errorMessage = 'Terjadi kesalahan sistem';
      errorDetails = widget.customDetails ?? widget.error.toString();
    }
  }

  void _handleRetry() async {
    if (widget.onRetry == null) return;

    if (widget.showLoadingOnRetry) {
      setState(() {
        _isRetrying = true;
      });

      // Show loading for a minimum duration if specified
      if (widget.loadingDuration != null) {
        await Future.delayed(widget.loadingDuration!);
      }
    }

    // Call the original retry callback
    widget.onRetry!();

    // Reset loading state if needed
    if (widget.showLoadingOnRetry && mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while retrying
    if (_isRetrying && widget.showLoadingOnRetry) {
      return Center(
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: widget.alignment ?? MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                widget.loadingMessage ?? 'Memuat ulang...',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: widget.alignment ?? MainAxisAlignment.center,
        children: [
          Icon(errorIcon, size: 48, color: errorIconColor),
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
          if (errorDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorDetails,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.showRetryButton && widget.onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRetrying ? null : _handleRetry,
              child:
                  _isRetrying
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(widget.retryButtonText ?? 'Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }
}

// Convenience widget for Riverpod consumers
class CustomErrorWidgetWithProvider extends ConsumerStatefulWidget {
  final Object error;
  final ProviderBase<Object?> provider;
  final String? logTag;
  final String? customMessage;
  final String? customDetails;
  final IconData? customIcon;
  final Color? iconColor;
  final String? retryButtonText;
  final EdgeInsets? padding;
  final MainAxisAlignment? alignment;
  final Duration? loadingDuration;

  const CustomErrorWidgetWithProvider({
    super.key,
    required this.error,
    required this.provider,
    this.logTag,
    this.customMessage,
    this.customDetails,
    this.customIcon,
    this.iconColor,
    this.retryButtonText,
    this.padding,
    this.alignment,
    this.loadingDuration = const Duration(milliseconds: 500),
  });

  @override
  ConsumerState<CustomErrorWidgetWithProvider> createState() =>
      _CustomErrorWidgetWithProviderState();
}

class _CustomErrorWidgetWithProviderState
    extends ConsumerState<CustomErrorWidgetWithProvider> {
  bool _isRetrying = false;

  void _handleRetry() async {
    setState(() {
      _isRetrying = true;
    });

    AppLogger.info(
      'Retrying provider: ${widget.provider.toString()}',
      tag: widget.logTag ?? 'CustomErrorWidget',
    );

    // Invalidate the provider to trigger reload
    ref.invalidate(widget.provider);

    // Show loading for a minimum duration to provide visual feedback
    if (widget.loadingDuration != null) {
      await Future.delayed(widget.loadingDuration!);
    }

    // Reset the retrying state
    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while retrying
    if (_isRetrying) {
      return Container(
        padding: widget.padding ?? const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: widget.alignment ?? MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Memuat ulang...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show error widget with retry functionality
    return CustomErrorWidget(
      error: widget.error,
      customMessage: widget.customMessage,
      customDetails: widget.customDetails,
      customIcon: widget.customIcon,
      iconColor: widget.iconColor,
      retryButtonText: widget.retryButtonText,
      padding: widget.padding,
      alignment: widget.alignment,
      onRetry: _handleRetry,
    );
  }
}
