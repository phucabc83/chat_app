import 'package:chat_app/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<User> getUserById(int userId);
}