import 'package:flutter/material.dart';
import 'package:nimbrung_mobile/pages/register/register_page.dart';

import 'pages/login/login_page.dart';
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
      home: Scaffold(body: RegisterPage()),
    );
  }
}
