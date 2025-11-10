import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository _authRepository;

  SignUpUsecase(this._authRepository);

  Future<void> call(String name,String email, String password, int avatarId) async {
    try {
       await _authRepository.signUpWithEmailAndPassword(email, password,name,avatarId);
    } catch (e) {
      print('Error during login: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}