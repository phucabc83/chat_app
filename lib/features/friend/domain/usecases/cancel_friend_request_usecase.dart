import '../repositories/friend_repository.dart';

class CancelFriendRequestUseCase {
  final FriendRepository repository;

  CancelFriendRequestUseCase(this.repository);

  Future<void> call(int requestId) async {
    await repository.cancelFriendRequest(requestId);
  }
}
