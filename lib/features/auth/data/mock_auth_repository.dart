class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });
}

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<void> signUp(String fullName, String email, String password);
  Future<void> forgotPassword(String email);
  Future<bool> verifyOTP(String code);
  Future<void> logout();
  Future<User?> getCurrentUser();
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'musamwange2@gmail.com' && password == '23748124') {
      _currentUser = User(
        id: '1',
        fullName: 'MUSA',
        email: email,
        phoneNumber: '0114945842',
      );
      return _currentUser;
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<void> signUp(String fullName, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: '2',
      fullName: fullName,
      email: email,
      phoneNumber: '0114945842',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> verifyOTP(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    if (code == '123456') {
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }
}
