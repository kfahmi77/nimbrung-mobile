import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/register.dart';
import '../state/auth_state.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterNotifier({required RegisterUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
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
      },
    );
  }

  void resetState() {
    AppLogger.debug('Resetting register state', tag: 'RegisterNotifier');
    state = const RegisterInitial();
  }
}
