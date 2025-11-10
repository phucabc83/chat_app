import '../repositories/friend_repository.dart';

class SendFriendRequestUseCase {
  final FriendRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call({
    required int receiverId,
    String? message,
  }) async {
    await repository.sendFriendRequest(receiverId, message: message);
  }
}
