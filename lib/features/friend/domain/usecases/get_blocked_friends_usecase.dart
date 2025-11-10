import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetBlockedFriendsUseCase {
  final FriendRepository repository;

  GetBlockedFriendsUseCase(this.repository);

  Future<List<Friend>> call() async {
    return await repository.getBlockedFriends();
  }
}
