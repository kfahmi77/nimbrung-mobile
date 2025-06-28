import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_avatar.dart';
import '../state/user_state.dart';

class UserProfileNotifier extends StateNotifier<UserState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;

  UserProfileNotifier(
    this._getUserProfileUseCase,
    this._updateProfileUseCase,
    this._updateAvatarUseCase,
  ) : super(UserInitial());

  Future<void> getUserProfile(String userId) async {
    state = UserLoading();

    final result = await _getUserProfileUseCase(userId);

    result.fold(
      (failure) => state = UserError(failure.message),
      (user) => state = UserLoaded(user),
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? username,
    String? fullname,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? gender,
  }) async {
    state = UserLoading();

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        userId: userId,
        username: username,
        fullname: fullname,
        bio: bio,
        birthPlace: birthPlace,
        dateBirth: dateBirth,
        preferenceId: preferenceId,
        gender: gender,
      ),
    );

    result.fold(
      (failure) => state = UserError(failure.message),
      (user) => state = UserLoaded(user),
    );
  }

  Future<void> updateAvatar({
    required String userId,
    required String avatarPath,
  }) async {
    state = UserLoading();

    final result = await _updateAvatarUseCase(
      UpdateAvatarParams(userId: userId, avatarPath: avatarPath),
    );

    result.fold(
      (failure) => state = UserError(failure.message),
      (user) => state = UserLoaded(user),
    );
  }
}
