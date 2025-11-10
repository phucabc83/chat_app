import 'package:equatable/equatable.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendEvent {}

class LoadFriendRequests extends FriendEvent {}

class SendFriendRequest extends FriendEvent {
  final int receiverId;
  final String? message;

  const SendFriendRequest({
    required this.receiverId,
    this.message,
  });

  @override
  List<Object?> get props => [receiverId, message];
}

class AcceptFriendRequest extends FriendEvent {
  final int requestId;
  final int friendId;

  const AcceptFriendRequest(this.requestId, this.friendId);

  @override
  List<Object?> get props => [requestId,friendId];
}

class RejectFriendRequest extends FriendEvent {
  final int requestId;

  const RejectFriendRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RemoveFriend extends FriendEvent {
  final int friendId;

  const RemoveFriend(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

class BlockFriend extends FriendEvent {
  final int friendId;

  const BlockFriend(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

class SearchUsers extends FriendEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends FriendEvent {}
