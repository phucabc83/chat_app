import 'package:chat_app/features/conversation/domain/repositories/user_repository.dart';

import '../../../auth/domain/entities/user.dart';

class FetchAllUserUseCase {
  final UserRepository userRepository;
  FetchAllUserUseCase(this.userRepository);

  Future<List<User>> execute() async {
    final data = await userRepository.getAllUsers();
    return data;
  }
}