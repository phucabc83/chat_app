import '../entities/friend.dart';
import '../entities/friend_request.dart';

abstract class FriendRepository {
  // Friend management
  Future<List<Friend>> getFriends();
  Future<Friend?> getFriendById(String id);
  Future<void> removeFriend(int friendId);
  Future<void> blockFriend(int friendId);
  Future<void> unblockFriend(int friendId);
  Future<List<Friend>> getBlockedFriends();
  Future<List<Friend>> searchFriends(String query);

  // Friend requests
  Future<List<FriendRequest>> getFriendRequests();
  Future<List<FriendRequest>> getSentFriendRequests();
  Future<void> sendFriendRequest(int receiverId, {String? message});
  Future<void> acceptFriendRequest(int requestId,int friendId);
  Future<void> rejectFriendRequest(int requestId);
  Future<void> cancelFriendRequest(int requestId);

  // User search
  Future<List<Friend>> searchUsers(String query);

  Future<List<Friend>> getNotFriends();

}
