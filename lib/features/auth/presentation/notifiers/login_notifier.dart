import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/login.dart';
import '../state/auth_state.dart';
import '../providers/auth_providers.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;
  final Ref _ref;

  LoginNotifier({required LoginUseCase loginUseCase, required Ref ref})
    : _loginUseCase = loginUseCase,
      _ref = ref,
      super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    AppLogger.info('Starting login process', tag: 'LoginNotifier');

    state = const LoginLoading();

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Login failed: ${failure.message}',
          tag: 'LoginNotifier',
        );
        state = LoginFailure(message: failure.message);
      },
      (user) {
        AppLogger.info('Login successful', tag: 'LoginNotifier');
        state = LoginSuccess(user: user);

        // Update app auth state
        _ref.read(appAuthNotifierProvider.notifier).setAuthenticated(user);
      },
    );
  }

  void resetState() {
    AppLogger.debug('Resetting login state', tag: 'LoginNotifier');
    state = const LoginInitial();
  }
}
