import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nimbrung_mobile/themes/app_fonts.dart';

import 'themes/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/chat.svg',
                width: 100,
                height: 100,
              ),
              Text(
                'Hello World!',
                style: TextStyle(fontFamily: 'SourceSansPro', fontSize: 24),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
