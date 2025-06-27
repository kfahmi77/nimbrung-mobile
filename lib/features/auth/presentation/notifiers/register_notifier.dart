import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/register.dart';
import '../state/auth_state.dart';
import '../providers/auth_providers.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final RegisterUseCase _registerUseCase;
  final Ref _ref;

  RegisterNotifier({required RegisterUseCase registerUseCase, required Ref ref})
    : _registerUseCase = registerUseCase,
      _ref = ref,
      super(const RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  }) async {
    AppLogger.info('Starting registration process', tag: 'RegisterNotifier');

    state = const RegisterLoading();

    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        username: username,
        fullname: fullname,
        gender: gender,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Registration failed: ${failure.message}',
          tag: 'RegisterNotifier',
        );
        state = RegisterFailure(message: failure.message);
      },
      (user) {
        AppLogger.info('Registration successful', tag: 'RegisterNotifier');
        state = RegisterSuccess(
          user: user,
          message: 'Registrasi berhasil! Silakan cek email untuk verifikasi.',
        );

        // Update app auth state
        _ref.read(appAuthNotifierProvider.notifier).setAuthenticated(user);
      },
    );
  }

  void resetState() {
    AppLogger.debug('Resetting register state', tag: 'RegisterNotifier');
    state = const RegisterInitial();
  }
}
