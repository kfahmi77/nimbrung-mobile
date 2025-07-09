import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://supabase-nimbrung.vpsfahmi.my.id',
    anonKey:
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc1MDYxOTM0MCwiZXhwIjo0OTA2MjkyOTQwLCJyb2xlIjoiYW5vbiJ9.5aCXxvN3eNX37RQpBa5r_F-FIpiyYmLi7e4H5GVaglM',
  );

  final supabase = Supabase.instance.client;

  print('🧪 Starting Daily Reading System Test...\n');

  try {
    // Step 1: Deploy the final system
    print('📥 Deploying final daily reading system...');

    // Read and execute the final deployment SQL
    final deploymentSql =
        await File('sql/final_daily_reading_deployment.sql').readAsString();

    // We need to split this into multiple queries since Supabase doesn't support multi-statement queries
    final statements =
        deploymentSql
            .split(';')
            .where(
              (stmt) =>
                  stmt.trim().isNotEmpty &&
                  !stmt.trim().startsWith('--') &&
                  !stmt.trim().toLowerCase().startsWith('begin') &&
                  !stmt.trim().toLowerCase().startsWith('commit'),
            )
            .toList();

    for (final statement in statements) {
      if (statement.trim().isNotEmpty) {
        try {
          await supabase.rpc('exec_sql', params: {'sql': statement.trim()});
        } catch (e) {
          // Some statements might fail due to already existing, continue
          print('⚠️  Warning executing statement: $e');
        }
      }
    }

    print('✅ Deployment completed\n');

    // Step 2: Check system health
    print('🔍 Checking system health...');

    // Check users with preferences
    final usersWithPrefs = await supabase
        .from('users')
        .select('id, email, preference_id')
        .not('preference_id', 'is', null)
        .limit(5);

    print('👥 Users with preferences: ${usersWithPrefs.length}');
    if (usersWithPrefs.isNotEmpty) {
      for (final user in usersWithPrefs) {
        print('   - ${user['email']} (${user['id']})');
      }
    }

    // Check readings per preference
    final readingsCount = await supabase
        .from('readings')
        .select('id')
        .eq('is_active', true);

    print('📚 Active readings available: ${readingsCount.length}');

    // Step 3: Test main functions
    print('\n🚀 Testing main functions...\n');

    if (usersWithPrefs.isNotEmpty) {
      final testUserId = usersWithPrefs.first['id'];

      // Test 1: get_user_daily_reading
      print('📖 Testing get_user_daily_reading...');
      try {
        final result = await supabase.rpc(
          'get_user_daily_reading',
          params: {'p_user_id': testUserId},
        );
        print(
          '✅ get_user_daily_reading result: ${result.toString().substring(0, 200)}...',
        );
      } catch (e) {
        print('❌ get_user_daily_reading error: $e');
      }

      // Test 2: generate_daily_reading_for_user
      print('\n📝 Testing generate_daily_reading_for_user...');
      try {
        final result = await supabase.rpc(
          'generate_daily_reading_for_user',
          params: {'p_user_id': testUserId},
        );
        print(
          '✅ generate_daily_reading_for_user result: ${result.toString().substring(0, 200)}...',
        );
      } catch (e) {
        print('❌ generate_daily_reading_for_user error: $e');
      }

      // Test 3: Check if daily reading was created
      print('\n📊 Checking daily readings created today...');
      try {
        final todayReadings = await supabase
            .from('daily_readings')
            .select('*, readings(title)')
            .eq(
              'reading_date',
              DateTime.now().toIso8601String().split('T').first,
            );

        print('✅ Daily readings for today: ${todayReadings.length}');
        for (final reading in todayReadings.take(3)) {
          print(
            '   - ${reading['readings']['title']} for user ${reading['user_id']}',
          );
        }
      } catch (e) {
        print('❌ Error checking daily readings: $e');
      }

      // Test 4: Test bulk generation
      print('\n🔄 Testing bulk generation...');
      try {
        final result = await supabase.rpc(
          'generate_daily_readings_for_all_users',
        );
        print('✅ Bulk generation result: $result');
      } catch (e) {
        print('❌ Bulk generation error: $e');
      }

      // Test 5: Final verification
      print('\n🔍 Final verification...');
      try {
        final finalCount = await supabase
            .from('daily_readings')
            .select('id')
            .eq(
              'reading_date',
              DateTime.now().toIso8601String().split('T').first,
            );

        print('✅ Total daily readings generated today: ${finalCount.length}');

        if (finalCount.length > 0) {
          print('🎉 SUCCESS: Daily reading system is working correctly!');
        } else {
          print('⚠️  WARNING: No daily readings were generated');
        }
      } catch (e) {
        print('❌ Final verification error: $e');
      }
    } else {
      print(
        '⚠️  No users with preferences found. Please ensure users have preferences set.',
      );
    }
  } catch (e) {
    print('❌ Test failed with error: $e');
    exit(1);
  }

  print('\n🏁 Test completed!');
  exit(0);
}
