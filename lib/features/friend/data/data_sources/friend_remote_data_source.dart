import 'package:chat_app/features/friend/domain/entities/friend.dart';
import 'package:chat_app/features/friend/domain/entities/friend_request.dart';

import '../models/friend_request_model.dart';

abstract class FriendRemoteDataSource {
  Future<List<Friend>> getFriends();
  Future<void> addFriend(Friend friend);
  Future<void> removeFriend(int friendId);
  Future<void> sendFriendRequest(int receiverId, {String? message});
  Future<List<FriendRequestModel>> getFriendRequests();

  Future<void> acceptFriendRequest(int requestId,int friendId);

  Future<void> rejectFriendRequest(int requestId);

  Future<List<Friend>> getNotFriends() ;

}