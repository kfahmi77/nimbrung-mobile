import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../../../core/usecases/usecase.dart';
import '../state/auth_state.dart';

class CurrentUserNotifier extends StateNotifier<CurrentUserState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  CurrentUserNotifier({required GetCurrentUserUseCase getCurrentUserUseCase})
    : _getCurrentUserUseCase = getCurrentUserUseCase,
      super(const CurrentUserInitial());

  Future<void> getCurrentUser() async {
    AppLogger.info('Getting current user', tag: 'CurrentUserNotifier');

    state = const CurrentUserLoading();

    final result = await _getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        AppLogger.error(
          'Get current user failed: ${failure.message}',
          tag: 'CurrentUserNotifier',
        );
        state = CurrentUserError(message: failure.message);
      },
      (user) {
        AppLogger.info(
          'Current user retrieved successfully',
          tag: 'CurrentUserNotifier',
        );
        state = CurrentUserLoaded(user: user);
      },
    );
  }

  void resetState() {
    AppLogger.debug('Resetting current user state', tag: 'CurrentUserNotifier');
    state = const CurrentUserInitial();
  }
}
