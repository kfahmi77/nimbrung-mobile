import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nimbrung_mobile/presentation/routes/app_route.dart';
import 'package:nimbrung_mobile/core/config/supabase_config.dart';
import 'package:nimbrung_mobile/core/services/image_upload_service.dart';

import 'presentation/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Note: Replace with your actual Supabase credentials
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');

    // Initialize storage buckets for different features
    final imageUploadService = ImageUploadService();
    await imageUploadService.initializeCommonBuckets();
    debugPrint('Storage buckets initialized');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
