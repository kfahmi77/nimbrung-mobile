import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../themes/color_schemes.dart';

class AppbarWidget extends ConsumerStatefulWidget {
  const AppbarWidget({super.key});

  @override
  ConsumerState<AppbarWidget> createState() => _AppbarWidgetState();
}

class _AppbarWidgetState extends ConsumerState<AppbarWidget> {
  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hamburger menu icon
        InkWell(
          onTap: _openDrawer,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),

        12.width,
        
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
            ),
          ),
        ),

        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pagi,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Nimbrung',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Spacer(),
        // Icons
        InkWell(
          onTap: () {
            context.go('/home/chat');
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/chat.svg',
              width: 22,
              height: 22,
            ),
          ),
        ),
        8.width,
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/images/bell.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}
