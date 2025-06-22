import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import 'custom_error.dart';

/// Helper class for creating common error widgets
class ErrorHelpers {
  ErrorHelpers._();

  /// Creates a network error widget
  static Widget networkError({
    VoidCallback? onRetry,
    String? customMessage,
    bool showLoadingOnRetry = true,
  }) {
    return CustomErrorWidget(
      error: const NetworkFailure(),
      customMessage: customMessage ?? 'Tidak ada koneksi internet',
      customDetails: 'Periksa koneksi internet Anda dan coba lagi.',
      customIcon: Icons.wifi_off,
      iconColor: Colors.orange[400],
      onRetry: onRetry,
      showLoadingOnRetry: showLoadingOnRetry,
    );
  }

  /// Creates a server error widget
  static Widget serverError({
    VoidCallback? onRetry,
    String? customMessage,
    String? errorDetails,
    bool showLoadingOnRetry = true,
  }) {
    return CustomErrorWidget(
      error: ServerFailure(
        message: errorDetails ?? 'Server error',
        code: 'SERVER_ERROR',
      ),
      customMessage: customMessage ?? 'Server bermasalah',
      customDetails:
          errorDetails ?? 'Terjadi kesalahan pada server. Silakan coba lagi.',
      customIcon: Icons.dns_outlined,
      onRetry: onRetry,
      showLoadingOnRetry: showLoadingOnRetry,
    );
  }

  /// Creates a general error widget
  static Widget generalError({
    required Object error,
    VoidCallback? onRetry,
    String? customMessage,
    String? customDetails,
    bool showLoadingOnRetry = true,
  }) {
    return CustomErrorWidget(
      error: error,
      customMessage: customMessage,
      customDetails: customDetails,
      onRetry: onRetry,
      showLoadingOnRetry: showLoadingOnRetry,
    );
  }

  /// Creates an error widget with provider integration
  static Widget providerError({
    required Object error,
    required ProviderBase<Object?> provider,
    required WidgetRef ref,
    String? logTag,
    String? customMessage,
    String? customDetails,
    IconData? customIcon,
    Color? iconColor,
  }) {
    return CustomErrorWidgetWithProvider(
      error: error,
      provider: provider,
      logTag: logTag,
      customMessage: customMessage,
      customDetails: customDetails,
      customIcon: customIcon,
      iconColor: iconColor,
    );
  }

  /// Creates a compact error widget for smaller spaces
  static Widget compactError({
    required Object error,
    VoidCallback? onRetry,
    String? message,
    bool showLoadingOnRetry = false,
  }) {
    return CustomErrorWidget(
      error: error,
      customMessage: message ?? 'Terjadi kesalahan',
      showRetryButton: onRetry != null,
      onRetry: onRetry,
      padding: const EdgeInsets.all(8),
      alignment: MainAxisAlignment.start,
      showLoadingOnRetry: showLoadingOnRetry,
    );
  }

  /// Creates an error widget without retry button
  static Widget infoError({
    required Object error,
    String? message,
    String? details,
    IconData? icon,
    Color? iconColor,
  }) {
    return CustomErrorWidget(
      error: error,
      customMessage: message,
      customDetails: details,
      customIcon: icon,
      iconColor: iconColor,
      showRetryButton: false,
    );
  }
}

/// Extension for easy error widget creation
extension ErrorWidgetExtension on Object {
  /// Convert any error to a CustomErrorWidget
  Widget toErrorWidget({
    VoidCallback? onRetry,
    String? customMessage,
    String? customDetails,
    IconData? customIcon,
    Color? iconColor,
    bool showRetryButton = true,
    bool showLoadingOnRetry = false,
  }) {
    return CustomErrorWidget(
      error: this,
      onRetry: onRetry,
      customMessage: customMessage,
      customDetails: customDetails,
      customIcon: customIcon,
      iconColor: iconColor,
      showRetryButton: showRetryButton,
      showLoadingOnRetry: showLoadingOnRetry,
    );
  }

  /// Convert error to provider-aware error widget
  Widget toProviderErrorWidget({
    required ProviderBase<Object?> provider,
    required WidgetRef ref,
    String? logTag,
    String? customMessage,
    String? customDetails,
  }) {
    return CustomErrorWidgetWithProvider(
      error: this,
      provider: provider,
      logTag: logTag,
      customMessage: customMessage,
      customDetails: customDetails,
    );
  }
}
