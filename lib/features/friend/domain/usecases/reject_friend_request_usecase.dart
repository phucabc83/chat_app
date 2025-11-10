import '../repositories/friend_repository.dart';

class RejectFriendRequestUseCase {
  final FriendRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<void> call(int requestId) async {
    await repository.rejectFriendRequest(requestId);
  }
}
