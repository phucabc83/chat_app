import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friend_repository.dart';
import '../data_sources/friend_remote_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Friend>> getFriends() async {
    try {
      final friendModels = await remoteDataSource.getFriends();
      return friendModels;
    } catch (e) {
      throw Exception('Failed to get friends: $e');
    }
  }

  @override
  Future<Friend?> getFriendById(String id) async {
    try {
      // return await remoteDataSource.getFriendById(id);
      return null; // Placeholder for actual implementation
    } catch (e) {
      throw Exception('Failed to get friend by id: $e');
    }
  }

  @override
  Future<void> removeFriend(int friendId) async {
    try {
      await remoteDataSource.removeFriend(friendId);
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  @override
  Future<void> blockFriend(int friendId) async {
    try {
      // await remoteDataSource.blockFriend(friendId);
    } catch (e) {
      throw Exception('Failed to block friend: $e');
    }
  }

  @override
  Future<void> unblockFriend(int friendId) async {
    try {
      // await remoteDataSource.unblockFriend(friendId);
    } catch (e) {
      throw Exception('Failed to unblock friend: $e');
    }
  }

  @override
  Future<List<Friend>> getBlockedFriends() async {
    try {
      // final friendModels = await remoteDataSource.getBlockedFriends();
      return [];
    } catch (e) {
      throw Exception('Failed to get blocked friends: $e');
    }
  }

  @override
  Future<List<Friend>> searchFriends(String query) async {
    try {
      // final friendModels = await remoteDataSource.searchFriends(query);
      return [];
    } catch (e) {
      throw Exception('Failed to search friends: $e');
    }
  }

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      final requestModels = await remoteDataSource.getFriendRequests();
      return requestModels;
    } catch (e) {
      throw Exception('Failed to get friend requests: $e');
    }
  }

  @override
  Future<List<FriendRequest>> getSentFriendRequests() async {
    try {
      // final requestModels = await remoteDataSource.getSentFriendRequests();
      return [];
    } catch (e) {
      throw Exception('Failed to get sent friend requests: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(int receiverId, {String? message}) async {
    try {
      await remoteDataSource.sendFriendRequest(receiverId, message: message);
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(int requestId,int friendId) async {
    try {
      await remoteDataSource.acceptFriendRequest(requestId,friendId);
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> rejectFriendRequest(int requestId) async {
    try {
      await remoteDataSource.rejectFriendRequest(requestId);
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }

  @override
  Future<void> cancelFriendRequest(int requestId) async {
    try {
      // await remoteDataSource.cancelFriendRequest(requestId);
    } catch (e) {
      throw Exception('Failed to cancel friend request: $e');
    }
  }

  @override
  Future<List<Friend>> searchUsers(String query) async {
    try {
      // final userModels = await remoteDataSource.searchUsers(query);
      return [];
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }



  @override
  Future<List<Friend>> getNotFriends() async{
     final data =await remoteDataSource.getNotFriends();
     return data;
  }
}
