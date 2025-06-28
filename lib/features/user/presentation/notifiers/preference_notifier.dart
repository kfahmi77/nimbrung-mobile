import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_preferences.dart';
import '../state/preference_state.dart';

class PreferenceNotifier extends StateNotifier<PreferenceState> {
  final GetPreferencesUseCase _getPreferencesUseCase;

  PreferenceNotifier(this._getPreferencesUseCase) : super(PreferenceInitial());

  Future<void> getPreferences() async {
    state = PreferenceLoading();

    final result = await _getPreferencesUseCase(NoParams());

    result.fold(
      (failure) => state = PreferenceError(failure.message),
      (preferences) => state = PreferencesLoaded(preferences),
    );
  }
}
