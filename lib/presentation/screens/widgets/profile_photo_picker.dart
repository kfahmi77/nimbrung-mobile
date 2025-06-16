import 'package:flutter/material.dart';

import '../../themes/color_schemes.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final String label;
  final VoidCallback? onAddPhoto;
  final ImageProvider? imageProvider;

  const ProfilePhotoPicker({
    super.key,
    required this.label,
    this.onAddPhoto,
    this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4F4F4F),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.textPrimary,
                child: CircleAvatar(
                  radius: 59,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageProvider,
                  child:
                      imageProvider == null
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[500],
                          )
                          : null,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: onAddPhoto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
