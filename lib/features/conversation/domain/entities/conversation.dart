
import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final int conversationId;
  final bool isGroup;
  final String? nameGroup;
  String lastMessage;
  DateTime? lastMessageTime;
  final String friendUserName;
  final String? avatarUrl;
  int unreadCount; // 🔥 Thêm mới
  final int member; // Số lượng thành viên trong nhóm
  final int replyTo;

  Conversation({
    required this.conversationId,
    required this.isGroup,
    this.nameGroup,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.friendUserName,
    this.avatarUrl,
    required this.unreadCount,
    required this.member,
    this.replyTo = 0
  });

  Conversation copyWith({
    int? conversationId,
    bool? isGroup,
    String? nameGroup,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? friendUserName,
    String? avatarUrl,
    int? replyTo,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      isGroup: isGroup ?? this.isGroup,
      nameGroup: nameGroup ?? this.nameGroup,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      friendUserName: friendUserName ?? this.friendUserName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount, // Giữ nguyên unreadCount
      member: member, // Giữ nguyên số lượng thành viên
      replyTo: replyTo ?? this.replyTo,
    );
  }


  @override
  List<Object?> get props => [
    conversationId,
    isGroup,
    nameGroup,
    lastMessage,
    lastMessageTime,
    friendUserName,
    avatarUrl,
    replyTo
  ];
}
