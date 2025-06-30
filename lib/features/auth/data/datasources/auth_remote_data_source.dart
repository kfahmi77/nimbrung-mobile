import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../user/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Authentication methods
  Future<UserModel> loginEmail({
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle();

  Future<UserModel> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> isLoggedIn();

  /// Password reset
  Future<void> resetPassword(String email);
}
