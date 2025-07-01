import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/user_avatar.dart';
import '../../../../themes/color_schemes.dart';

/// Widget for displaying the user's profile picture with edit functionality
class UserProfileSection extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback? onCameraTap;

  const UserProfileSection({
    super.key,
    required this.isEditing,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Stack(
        children: [
          UserAvatar(radius: 60, borderColor: Colors.white, borderWidth: 4),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
