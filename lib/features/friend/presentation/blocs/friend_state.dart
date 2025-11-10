import 'package:equatable/equatable.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';

abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendLoaded extends FriendState {
  final List<Friend> friends;
  final List<FriendRequest> friendRequests;
  final List<Friend> notFriends;
  final List<Friend> searchResults;
  final bool isSearching;

  const FriendLoaded({
    required this.friends,
    required this.friendRequests,
    required this.notFriends,
    this.searchResults = const [],
    this.isSearching = false,
  });

  FriendLoaded copyWith({
    List<Friend>? friends,
    List<FriendRequest>? friendRequests,
    List<Friend>? searchResults,
    List<Friend>? notFriends,
    bool? isSearching

  }) {
    return FriendLoaded(
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      notFriends: notFriends ?? this.notFriends,
    );
  }

  @override
  List<Object?> get props => [friends, friendRequests, notFriends,searchResults, isSearching];
}

class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRequestSent extends FriendState {
  final String message;

  const FriendRequestSent(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRequestAccepted extends FriendState {
  final String message;

  const FriendRequestAccepted(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRemoved extends FriendState {
  final String message;

  const FriendRemoved(this.message);

  @override
  List<Object?> get props => [message];
}
