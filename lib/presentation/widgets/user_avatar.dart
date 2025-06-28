import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/notifiers/app_auth_notifier.dart';

/// A reusable widget for displaying user avatar
/// Automatically shows authenticated user's avatar or fallback image
class UserAvatar extends ConsumerWidget {
  final double radius;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final String? fallbackImageUrl;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.fallbackImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    // Determine avatar URL
    String avatarUrl;
    if (authState is AppAuthAuthenticated && authState.user.avatar != null) {
      avatarUrl = authState.user.avatar!;
    } else {
      avatarUrl =
          fallbackImageUrl ??
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face';
    }

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(avatarUrl),
    );

    // Add border if specified
    if (borderColor != null || borderWidth != null) {
      avatarWidget = CircleAvatar(
        radius: radius + (borderWidth ?? 2),
        backgroundColor: borderColor ?? Colors.white,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

/// A reusable widget for displaying user display name
/// Shows username, fullname, or fallback text based on availability
class UserDisplayName extends ConsumerWidget {
  final TextStyle? style;
  final String? fallbackText;
  final bool preferUsername; // If true, prefers username over fullname

  const UserDisplayName({
    super.key,
    this.style,
    this.fallbackText,
    this.preferUsername = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    String displayName;
    if (authState is AppAuthAuthenticated) {
      if (preferUsername) {
        displayName =
            authState.user.username ??
            authState.user.fullname ??
            fallbackText ??
            'Nimbrung User';
      } else {
        displayName =
            authState.user.fullname ??
            authState.user.username ??
            fallbackText ??
            'Nimbrung User';
      }
    } else {
      displayName = fallbackText ?? 'Nimbrung User';
    }

    return Text(displayName, style: style);
  }
}

/// A reusable widget for displaying user email
class UserEmail extends ConsumerWidget {
  final TextStyle? style;
  final String? fallbackEmail;

  const UserEmail({super.key, this.style, this.fallbackEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    String email;
    if (authState is AppAuthAuthenticated) {
      email = authState.user.email;
    } else {
      email = fallbackEmail ?? 'user@nimbrung.com';
    }

    return Text(email, style: style);
  }
}
