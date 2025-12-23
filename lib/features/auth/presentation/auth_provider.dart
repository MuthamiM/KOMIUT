import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null)) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    state = const AsyncValue.loading();
    final user = await _repository.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> verifyOTP(String code) async {
    final success = await _repository.verifyOTP(code);
    return success;
  }

  Future<void> signUp(String fullName, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(fullName, email, password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedUser = User(
        id: currentUser.id,
        fullName: name ?? currentUser.fullName,
        email: email ?? currentUser.email,
        phoneNumber: phone ?? currentUser.phoneNumber,
        avatarUrl: currentUser.avatarUrl,
      );
      state = AsyncValue.data(updatedUser);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
