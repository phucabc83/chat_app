import '../entities/friend_request.dart';
import '../repositories/friend_repository.dart';

class GetFriendRequestsUseCase {
  final FriendRepository repository;

  GetFriendRequestsUseCase(this.repository);

  Future<List<FriendRequest>> call() async {
    return await repository.getFriendRequests();
  }
}
