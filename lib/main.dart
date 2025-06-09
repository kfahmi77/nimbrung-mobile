import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbrung_mobile/core/routes/app_route.dart';
import 'package:nimbrung_mobile/pages/home/home_page.dart';
import 'package:nimbrung_mobile/pages/register_update/register_update_page.dart';
import 'package:nimbrung_mobile/pages/register/register_page.dart';

import 'pages/login/login_page.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
