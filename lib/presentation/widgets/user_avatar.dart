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

/// A reusable widget for displaying user bio
class UserBio extends ConsumerWidget {
  final TextStyle? style;
  final String? fallbackBio;
  final int? maxLines;
  final TextOverflow? overflow;

  const UserBio({
    super.key,
    this.style,
    this.fallbackBio,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    String bio;
    if (authState is AppAuthAuthenticated) {
      bio =
          authState.user.bio ??
          fallbackBio ??
          'Belum ada bio yang ditambahkan.';
    } else {
      bio = fallbackBio ?? 'Belum ada bio yang ditambahkan.';
    }

    return Text(bio, style: style, maxLines: maxLines, overflow: overflow);
  }
}

/// A reusable widget for displaying user preference name
/// Uses the preferenceName field from the joined preference table
class UserPreference extends ConsumerWidget {
  final TextStyle? style;
  final String? fallbackPreference;

  const UserPreference({super.key, this.style, this.fallbackPreference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthNotifierProvider);

    String preference;
    if (authState is AppAuthAuthenticated) {
      // Use the preferenceName field from the joined table
      preference =
          authState.user.preferenceName ?? fallbackPreference ?? 'Psikologi';
    } else {
      preference = fallbackPreference ?? 'Psikologi';
    }

    return Text(preference, style: style);
  }
}

/// A comprehensive widget that displays user information
/// Combines avatar, name, email, bio, and preference in a customizable layout
class UserInfoCard extends ConsumerWidget {
  final bool showAvatar;
  final bool showName;
  final bool showEmail;
  final bool showBio;
  final bool showPreference;
  final double? avatarRadius;
  final TextStyle? nameStyle;
  final TextStyle? emailStyle;
  final TextStyle? bioStyle;
  final TextStyle? preferenceStyle;
  final CrossAxisAlignment? alignment;
  final MainAxisSize? mainAxisSize;
  final EdgeInsetsGeometry? padding;
  final String? fallbackBio;
  final String? fallbackPreference;

  const UserInfoCard({
    super.key,
    this.showAvatar = true,
    this.showName = true,
    this.showEmail = true,
    this.showBio = true,
    this.showPreference = true,
    this.avatarRadius = 40,
    this.nameStyle,
    this.emailStyle,
    this.bioStyle,
    this.preferenceStyle,
    this.alignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.padding,
    this.fallbackBio,
    this.fallbackPreference,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment!,
        mainAxisSize: mainAxisSize!,
        children: [
          // Avatar
          if (showAvatar) ...[
            UserAvatar(
              radius: avatarRadius!,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
            const SizedBox(height: 16),
          ],

          // Name
          if (showName) ...[
            UserDisplayName(
              preferUsername: false,
              style:
                  nameStyle ??
                  const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
          ],

          // Email
          if (showEmail) ...[
            UserEmail(
              style:
                  emailStyle ??
                  TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
          ],

          // Preference
          if (showPreference) ...[
            UserPreference(
              fallbackPreference: fallbackPreference,
              style:
                  preferenceStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 16),
          ],

          // Bio
          if (showBio) ...[
            UserBio(
              fallbackBio: fallbackBio,
              style:
                  bioStyle ??
                  TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
