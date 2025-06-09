import 'package:flutter/material.dart';

import '../../themes/color_schemes.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24, right: 58, left: 58),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home_rounded, color: Colors.white, size: 28),
            Icon(Icons.search, color: Colors.white, size: 28),
            Icon(Icons.menu_book, color: Colors.white, size: 28),
            Icon(Icons.person, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
