import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<Friend>> call() async {
    return await repository.getFriends();
  }

  Future<List<Friend>> callNotFriends() async {
    return await repository.getNotFriends();
  }

}
