import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<User> call(String email, String password) async {
    try {
      return await _authRepository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      print('Error during login: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}