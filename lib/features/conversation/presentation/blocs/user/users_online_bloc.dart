import 'dart:async';

import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/conversation/presentation/blocs/user/users_online_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/service/socket_service.dart';
import '../../../../auth/domain/entities/user.dart';
import '../conversation/conversation_event.dart';

class UsersOnlineBloc extends Bloc<StatusUsersEvent, UsersOnlineState> {
  final SocketService _socketService;

  /// Lưu online theo userId -> User (tránh trùng, dễ cập nhật)
  final Map<int, User> _onlineById = <int, User>{};

  bool _initialized = false;

  UsersOnlineBloc(this._socketService) : super(UsersOnlineInitial()) {
    on<LoadStatusFriendsEvent>(_onLoadStatusFriends);
    on<UpdateOnlineFriendEvent>(_onUpdateFriend);
    on<GetListFriendsOnlineEvent>(_onLoadListFriendsOnline);
  }

  Future<void> _onLoadStatusFriends(
      StatusUsersEvent event,
      Emitter<UsersOnlineState> emit,
      ) async {
    if (_initialized) return;
    _initialized = true;

    // Nhận undelivered để client gửi bulkDelivered (đã chuẩn payload)
    _socketService.listenUndelivered();

    // Danh sách bạn đang online khi mình vừa connect
    _socketService.listenGetListFriendsOnline((users) {
      add(GetListFriendsOnlineEvent(users));
    });

    // Bạn online/offline realtime
    _socketService.listenOnlineFriends((user, isOnline) {
      add(UpdateOnlineFriendEvent(user, isOnline));
    });
  }

  void _onUpdateFriend(
      UpdateOnlineFriendEvent event,
      Emitter<UsersOnlineState> emit,
      ) {
    // Bỏ qua chính mình & khi userId chưa khởi tạo
    if (event.user.id == Util.userId || Util.userId == 0) return;

    final id = event.user.id;

    if (event.isOnline) {
      final existed = _onlineById.containsKey(id);
      if (!existed) {
        _onlineById[id] = event.user;
        emit(UsersOnlineLoaded(List<User>.from(_onlineById.values)));
      }
    } else {
      if (_onlineById.containsKey(id)) {
        _onlineById.remove(id);
        emit(UsersOnlineLoaded(List<User>.from(_onlineById.values)));
      }
    }
  }

  void _onLoadListFriendsOnline(
      GetListFriendsOnlineEvent event,
      Emitter<UsersOnlineState> emit,
      ) {
    _onlineById
      ..clear()
      ..addEntries(
        event.users
            .where((u) => u.id != Util.userId) // bỏ chính mình
            .map((u) => MapEntry(u.id, u)),
      );

    emit(UsersOnlineLoaded(List<User>.from(_onlineById.values)));
  }

  @override
  Future<void> close() {
    // Dọn listener để tránh memory leak khi BLoC bị dispose hoặc hot-reload
    try {
      _socketService.offUndelivered();
      _socketService.offListFriendsOnline();
      _socketService.offOnlineFriends();
    } catch (_) {
      // ignore
    }
    return super.close();
  }
}
