import '../repositories/friend_repository.dart';

class UnblockFriendUseCase {
  final FriendRepository repository;

  UnblockFriendUseCase(this.repository);

  Future<void> call(int friendId) async {
    await repository.unblockFriend(friendId);
  }
}
