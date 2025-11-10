import '../entities/user.dart';

abstract class AuthRepository{
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password,String name, int avatarId);
  Future<void> signOut();

}