import '../repositories/friend_repository.dart';

class RemoveFriendUseCase {
  final FriendRepository repository;

  RemoveFriendUseCase(this.repository);

  Future<void> call(int friendId) async {
    await repository.removeFriend(friendId);
  }
}
