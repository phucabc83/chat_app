import '../repositories/friend_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<void> call(int requestId,int friendId) async {
    await repository.acceptFriendRequest(requestId,friendId);
  }
}
