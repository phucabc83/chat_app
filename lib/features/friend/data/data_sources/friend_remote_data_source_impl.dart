import 'package:chat_app/core/service/api_service.dart';
import 'package:chat_app/features/friend/domain/entities/friend_request.dart';

import '../../domain/entities/friend.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import 'friend_remote_data_source.dart';

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final ApiService _friendApi;

  FriendRemoteDataSourceImpl(this._friendApi);

  @override
  Future<List<Friend>> getFriends() async {
    try {
      final response = await _friendApi.getFriends();
      return response.map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load friends: $e');
    }
  }

  @override
  Future<void> addFriend(Friend friend) async {
    try {
      await _friendApi.addFriend(friend.toJson());
    } catch (e) {
      throw Exception('Failed to add friend: $e');
    }
  }

  @override
  Future<void> removeFriend(int friendId) async {
    try {
      await _friendApi.removeFriend(friendId);
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(int receiverId, {String? message}) async {
      await _friendApi.sendFriendRequest(
        receiverId: receiverId,
        message: message,
      );
  }

  @override
  Future<List<FriendRequestModel>> getFriendRequests() async{
    try {
      final response = await _friendApi.getFriendRequests();
      return response.map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load friend requests: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(int requestId,int friendId) async{
      await _friendApi.acceptFriendRequest(requestId,friendId);
  }

  @override
  Future<void> rejectFriendRequest(int requestId) async {
    // TODO: implement rejectFriendRequest
    await _friendApi.rejectFriendRequest(requestId);
  }

  @override
  Future<List<Friend>> getNotFriends() {
    return _friendApi.getNotFriends().then((response) {
      return response.map((e) => FriendModel.fromJson(e)).toList();
    }).catchError((e) {
      throw Exception('Failed to load not friends: $e');
    });
  }

}