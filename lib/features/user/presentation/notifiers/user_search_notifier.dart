import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/search_users.dart';
import '../state/user_state.dart';

class UserSearchNotifier extends StateNotifier<UserState> {
  final SearchUsersUseCase _searchUsersUseCase;

  UserSearchNotifier(this._searchUsersUseCase) : super(UserInitial());

  Future<void> searchUsers({
    String? query,
    String? preferenceId,
    int limit = 20,
    int offset = 0,
  }) async {
    state = UserLoading();

    final result = await _searchUsersUseCase(
      SearchUsersParams(
        query: query,
        preferenceId: preferenceId,
        limit: limit,
        offset: offset,
      ),
    );

    result.fold((failure) => state = UserError(failure.message), (users) {
      // For search results, we'll create a special state
      // For now, using UserLoaded with first user or creating a new state type
      if (users.isNotEmpty) {
        state = UserLoaded(users.first);
      } else {
        state = const UserError('No users found');
      }
    });
  }
}
