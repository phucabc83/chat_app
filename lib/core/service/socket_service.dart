// lib/core/service/socket_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/messsage.dart'; // (đúng path của bạn)

typedef ReceiveMessageFun = void Function(Message);
typedef GetOnlineFriends = void Function(User, bool);
typedef GetListOnlineFriends = void Function(List<User>);

typedef OnReceiptUpdate =
void Function({
required int messageId,
required int userId,
required String type, // 'delivered' | 'read'
int? upTo,
int? conversationId,
});

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  late IO.Socket socket;
  bool _isInitialized = false;

  /// Tránh gửi delivered/read nhiều lần cho cùng 1 messageId
  final Set<int> _deliveredOnce = <int>{};

  /// ==========================
  /// KẾT NỐI
  /// ==========================
  void connect() {
    if (_isInitialized) return;

    socket = IO.io(
      Util.apiBaseUrl(),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setTimeout(10000)
          .setReconnectionDelay(1000)
          .build(),
    );

    _isInitialized = true;
    socket.connect();
    print('🟢 [Socket] Connecting...');

    socket.onConnect((_) {
      print('✅ [Socket] Connected');
      _markUserOnline();
    });

    socket.onDisconnect((_) {
      print('❌ [Socket] Disconnected');
      _deliveredOnce.clear();
    });

    socket.onConnectError((err) {
      print('⚠️ [Socket] Connect error: $err');
      Future.delayed(const Duration(seconds: 2), () {
        if (!socket.connected) socket.connect();
      });
    });

    socket.onReconnect((_) {
      print('🔄 [Socket] Reconnected');
      _markUserOnline();
    });
  }

  void _markUserOnline() {
    if (!socket.connected) return;
    socket.emit('Online', {
      'userId': Util.userId,
      'username': Util.userName,
      'avatar': Util.avatarUrl,
      'fcmToken': Util.fcmToken,
    });
  }

  /// Đăng xuất chủ động
  void logoutAndDisconnect() {
    if (!socket.connected) return;
    socket.emit('friendOffline');
    socket.disconnect();
    print('🔌 [Socket] Disconnected manually');
  }

  /// Đóng socket tạm thời (không gửi friendOffline)
  void disconnect() {
    if (!socket.connected) return;
    socket.disconnect();
    print('🔌 [Socket] Disconnected');
  }

  /// ==========================
  /// CONVERSATION ROOMS
  /// ==========================
  void joinConversation(int conversationId, bool isGroup) {
    if (!socket.connected) return;
    socket.emit('joinConversation', {
      'conversationId': conversationId,
      'isGroup': isGroup,
    });
    print('📥 [Socket] Joined conversation $conversationId');
  }

  void leaveConversation(int conversationId, bool isGroup) {
    if (!socket.connected) return;
    socket.emit('leaveConversation', {
      'conversationId': conversationId,
      'isGroup': isGroup,
    });
    print('📤 [Socket] Left conversation $conversationId');
  }

  /// ==========================
  /// GỬI TIN
  /// ==========================
  Future<Message> sendMessage({
    required int conversationId,
    required String content,
    required int senderId,
    required MessageType messageType,
    required String senderName,
    int? replyTo,
    required bool isGroup,
    String? fileNameImage,
    Uint8List? bytesImage,
    String? mimeType,
  }) {
    final completer = Completer<Message>();

    if (!socket.connected) {
      completer.completeError(Exception('Socket not connected'));
      return completer.future;
    }

    socket.emitWithAck(
      'sendMessage',
      {
        'conversationId': conversationId,
        'content': content,
        'senderId': senderId,
        'messageType': messageType.label,
        'replyTo': replyTo,
        'senderName': senderName,
        'isGroup': isGroup,
        'fileNameImage': fileNameImage,
        'bytesImage': bytesImage,
        'mimeType': mimeType,
      },
      ack: (resp) {
        print('📤 [Socket] Message sent ack: $resp');
        if (resp != null && resp['success'] == true) {
          final message = Message(
            id: resp['id'],
            content: resp['messageContent'],
            senderId: senderId,
            conversationId: conversationId,
            sentAt: DateTime.now(),
            messageType: messageType,
            replyTo: replyTo,
            senderName: senderName,
            deliveredCount: resp['deliveredCount'] ?? 0,
            readCount: resp['readCount'] ?? 0,
            totalRecipients: resp['totalRecipients'] ?? 0,
          );
          completer.complete(message);
        } else {
          completer.completeError(Exception(resp?['error'] ?? 'Unknown error'));
        }
      },
    );

    return completer.future;
  }

  /// ==========================
  /// NHẬN TIN Ở MÀN ĐANG MỞ CHAT
  /// ==========================
  void receiveMessageByPrivateOrGroup(ReceiveMessageFun onReceive,
      bool isGroup,) {
    final eventName = isGroup
        ? 'receiveMessage_group'
        : 'receiveMessage_private';

    // đảm bảo không nhân bản listener
    socket.off(eventName);

    socket.on(eventName, (data) {
      final message = Message.fromJson(data);
      print('📥 [Socket] Received message: $message');

      onReceive(message);

      // Ở màn đang mở => mark read upTo
      if (_shouldAckOnce(message.id)) {
        markMessageRead(
          conversationId: message.conversationId,
          userId: Util.userId,
          maxMessageId: message.id!,
        );
      }
    });
  }

  void offReceiveMessage(bool isGroup) {
    final eventName = isGroup
        ? 'receiveMessage_group'
        : 'receiveMessage_private';
    socket.off(eventName);
  }

  /// ==========================
  /// NHẬN TIN Ở MÀN DANH SÁCH CONVERSATION
  /// ==========================
  void conversationReceiveMessage(ReceiveMessageFun onReceive, bool isGroup) {
    final eventName = isGroup
        ? 'conversationUpdated_group'
        : 'conversationUpdated_private';

    // tránh đăng ký trùng
    socket.off(eventName);

    socket.on(eventName, (data) {
      print('📥 [Socket] Conversation update message: $data');
      final message = Message.fromJson(data);
      onReceive(message);

      // Ở list thì chỉ delivered (không read)
      if (_shouldAckOnce(message.id) && message.senderId != Util.userId) {
        onMessageDelivered(message.id!, message.conversationId);
      }
    });
  }

  /// ==========================
  /// RECEIPT: DELIVERED / READ
  /// ==========================
  void onMessageDelivered(int messageId, int conversationId) {
    if (!socket.connected) return;
    socket.emit('message:delivered', {
      "messageId": messageId,
      "userId": Util.userId,
      "conversationId": conversationId,
    });
  }

  void markMessageRead({
    required int conversationId,
    required int userId,
    required int maxMessageId,
  }) {
    debugPrint(
      '[Socket] Marking messages up to $maxMessageId as read in conversation $conversationId by user $userId',
    );
    if (!socket.connected) return;
    socket.emit('message:read', {
      'conversationId': conversationId,
      'userId': userId,
      'maxMessageId': maxMessageId,
    });
  }

  void listenReceiptUpdates(OnReceiptUpdate onUpdate) {
    // delivered (single)
    socket.off('message:receipt_update');
    socket.on('message:receipt_update', (data) {
      onUpdate(
        messageId: data['messageId'],
        userId: data['userId'],
        type: data['type'], // 'delivered'
        conversationId: data['conversationId'],
      );
    });
  }

  void onReadedMessage(OnReceiptUpdate onUpdate) {
    // read range (upTo)
    socket.off('message:receipt_update_range');
    socket.on('message:receipt_update_range', (data) {
      onUpdate(
        messageId: -1,
        userId: data['userId'],
        type: data['type'],
        // 'read'
        conversationId: data['conversationId'],
        upTo: data['upTo'],
      );
    });
  }

  void offDeliveredMessage() => socket.off('message:receipt_update');

  void offReadedMessage() => socket.off('message:receipt_update_range');

  /// ==========================
  /// UNDELIVERED → BULK DELIVERED
  /// ==========================
  void listenUndelivered() {
    socket.off('undeliveredMessages');
    print('📥 [Socket] Listening for undelivered messages');

    socket.on('undeliveredMessages', (data) {
      // server gửi dạng: [{ messageId, conversationId, ... }, ...]
      if (data is! List) return;

      final List<Map<String, dynamic>> items = [];
      for (final raw in data) {
        final msgId = raw['messageId'] ?? raw['id'];
        final convId = raw['conversationId'];
        if (msgId is int && convId is int) {
          if (_shouldAckOnce(msgId)) {
            items.add({'messageId': msgId, 'conversationId': convId});
          }
        }
      }

      if (items.isEmpty) return;

      socket.emit('bulkDelivered', {'userId': Util.userId, 'messages': items});

      // Không cần gọi onMessageDelivered lẻ;
      // server sẽ tự broadcast 'message:receipt_update' cho từng item.
    });
  }

  void offUndelivered() => socket.off('undeliveredMessages');

  /// ==========================
  /// ONLINE FRIENDS (dùng bởi UsersOnlineBloc)
  /// ==========================
  void listenGetListFriendsOnline(GetListOnlineFriends onListReceived) {
    socket.off('listFriendsOnline');
    socket.on('listFriendsOnline', (data) {
      if (data is! List) return;
      final users = data.map<User>((item) {
        return User.basic(
          id: item['userId'],
          name: item['username'],
          avatar: item['avatar'] ?? '',
        );
      }).toList();
      onListReceived(users);
    });
  }

  void listenOnlineFriends(GetOnlineFriends onStatusChange) {
    socket.off('friendOnline');
    socket.off('friendOffline');

    socket.on('friendOnline', (data) {
      final user = User.basic(
        id: data['userId'],
        name: data['username'],
        avatar: (data['avatar'] ?? '').toString(),
      );
      onStatusChange(user, true);
    });

    socket.on('friendOffline', (data) {
      final user = User.basic(
        id: data['userId'],
        name: (data['username'] ?? '').toString(),
        avatar: (data['avatar'] ?? '').toString(),
      );
      onStatusChange(user, false);
    });
  }

  void offListFriendsOnline() => socket.off('listFriendsOnline');

  void offOnlineFriends() {
    socket.off('friendOnline');
    socket.off('friendOffline');
  }

  /// ==========================
  /// TIỆN ÍCH
  /// ==========================
  bool _shouldAckOnce(int? messageId) {
    if (messageId == null) return false;
    if (_deliveredOnce.contains(messageId)) return false;
    _deliveredOnce.add(messageId);
    return true;
  }

  void makeCall(String callID, int userIdReceiver) {
    socket.emit('makeCall', {
      'callID': callID,
      'fromUserID': Util.userId,
      'toUserID': userIdReceiver,
      'fromUserName': Util.userName,
      'fromAvatarUrl': Util.avatarUrl,
    });
  }

  void listenCallReceived(Function(Map<String, dynamic>) onCallReceived) {
    socket.off('callReceived');
    socket.on('callReceived', (data) {
      debugPrint('[Socket] Call received: $data');

      onCallReceived(data);
    });
  }

  void listenCallAccepted(Function(Map<String, dynamic>) onCallAccepted) {
    socket.off('callAccepted');

    socket.on('callAccepted', (data) {
      debugPrint('[Socket] Call accepted: $data');
      onCallAccepted(data);
    });
  }

  acceptCall(String s, int i) {
    socket.emit('acceptCall', {
      'callID': s,
      'fromUserID': Util.userId,
      'toUserID': i,
    });
  }

  rejectCall(String s, int i) {
    socket.emit('rejectCall', {
      'callID': s,
      'fromUserID': Util.userId,
      'toUserID': i,
    });
  }

  void listenCallReject(Function() eventReject) {
    socket.off('callRejected');
    socket.on('callRejected', (data) {
      eventReject();
    });
  }

  void cancelCall(String callID, int userId, int toUserID) {
    debugPrint('[Socket] Cancel call: $callID');

    socket.emit('cancelCall', {

        'callID': callID,
        'fromUserID': userId,
        'toUserID': toUserID,
        });
  }

  void listenCancelCall(Function() eventCancelCall) {
    socket.off('callCanceled');
    socket.on('callCanceled', (data) {
      debugPrint('listen cancel call');

      eventCancelCall();
    });
  }
}
