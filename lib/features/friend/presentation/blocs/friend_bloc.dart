import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/util.dart';

import '../../domain/usecases/get_friend_requests_usecase.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/usecases/accept_friend_request_usecase.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../domain/usecases/remove_friend_usecase.dart';
import '../../domain/usecases/block_friend_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';
import 'friend_event.dart';
import 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final GetFriendsUseCase getFriendsUseCase;
  final GetFriendRequestsUseCase getFriendRequestsUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final RemoveFriendUseCase removeFriendUseCase;
  final BlockFriendUseCase blockFriendUseCase;
  final SearchUsersUseCase searchUsersUseCase;

  FriendBloc({
    required this.getFriendsUseCase,
    required this.getFriendRequestsUseCase,
    required this.sendFriendRequestUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.removeFriendUseCase,
    required this.blockFriendUseCase,
    required this.searchUsersUseCase,
  }) : super(FriendInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<BlockFriend>(_onBlockFriend);
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendState> emit) async {
    try {
      emit(FriendLoading());
      final friends = await getFriendsUseCase.call();
      final friendRequests = await getFriendRequestsUseCase();
      final notFriends = await getFriendsUseCase.callNotFriends();

      friends.removeWhere((friend) => friend.id == Util.userId);



      print('Loaded friends: ${friends.length}, Friend requests: ${friendRequests.length}');
      emit(FriendLoaded(
        friends: friends,
        friendRequests: friendRequests,
          notFriends:notFriends
      ));
    } catch (e) {
      emit(FriendError('Failed to load friends: ${e.toString()}'));
    }
  }

  Future<void> _onLoadFriendRequests(LoadFriendRequests event, Emitter<FriendState> emit) async {
    try {
      if (state is FriendLoaded) {
        final currentState = state as FriendLoaded;
        final friendRequests = await getFriendRequestsUseCase();

        emit(currentState.copyWith(friendRequests: friendRequests));
      }
    } catch (e) {
      emit(FriendError('Failed to load friend requests: ${e.toString()}'));
    }
  }

  Future<void> _onSendFriendRequest(SendFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await sendFriendRequestUseCase(
        receiverId: event.receiverId,
        message: event.message,
      );
      emit(const FriendRequestSent('Friend request sent successfully'));

      // Reload data
      add(LoadFriends());
    } catch (e) {
      emit(FriendError('Failed to send friend request: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptFriendRequest(AcceptFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await acceptFriendRequestUseCase(event.requestId,event.friendId);
      emit(const FriendRequestAccepted('Friend request accepted'));

      // Reload data
      add(LoadFriends());
    } catch (e) {
      emit(FriendError('Failed to accept friend request: ${e.toString()}'));
    }
  }

  Future<void> _onRejectFriendRequest(RejectFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await rejectFriendRequestUseCase(event.requestId);
      emit(const FriendRequestAccepted('Friend request rejected'));

      // Reload data
      add(LoadFriends());
    } catch (e) {
      emit(FriendError('Failed to reject friend request: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFriend(RemoveFriend event, Emitter<FriendState> emit) async {
    try {
      await removeFriendUseCase(event.friendId);
      emit(const FriendRemoved('Friend removed successfully'));
      add(LoadFriends());
    } catch (e) {
      emit(FriendError('Failed to remove friend: ${e.toString()}'));
    }
  }

  Future<void> _onBlockFriend(BlockFriend event, Emitter<FriendState> emit) async {
    try {
      await blockFriendUseCase(event.friendId);
      emit(const FriendRemoved('Friend blocked successfully'));

      // Reload data
      add(LoadFriends());
    } catch (e) {
      emit(FriendError('Failed to block friend: ${e.toString()}'));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<FriendState> emit) async {
    try {
      if (state is FriendLoaded) {
        final currentState = state as FriendLoaded;
        final searchResults = currentState.notFriends.where(
          (friend) => friend.name.toLowerCase().contains(event.query.toLowerCase())
        ).toList();

        emit(currentState.copyWith(
          searchResults: searchResults,
          isSearching: true,
        ));
      }
    } catch (e) {
      emit(FriendError('Failed to search users: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<FriendState> emit) async {
    if (state is FriendLoaded) {
      final currentState = state as FriendLoaded;
      emit(currentState.copyWith(
        searchResults: [],
        isSearching: false,
      ));
    }
  }
}
