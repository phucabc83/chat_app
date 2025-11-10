import '../repositories/friend_repository.dart';

class BlockFriendUseCase {
  final FriendRepository repository;

  BlockFriendUseCase(this.repository);

  Future<void> call(int friendId) async {
    await repository.blockFriend(friendId);
  }
}
