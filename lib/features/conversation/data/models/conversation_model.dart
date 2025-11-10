import '../../domain/entities/conversation.dart';

class ConversationModel {
  final int conversationId;
  final bool isGroup;
  final String? nameGroup;
  final String avatarUrl;

  final String lastMessage;
  final DateTime? lastMessageTime;
  final String friendUser;
  final int unreadCount; // 🔥 Thêm mới
  final int member ;
  final int replyTo;

  ConversationModel({
    required this.conversationId,
    required this.isGroup,
    this.nameGroup,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.friendUser,
    required this.avatarUrl,
    required this.unreadCount,
    required this.member ,
    this.replyTo = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ConversationModel(
        conversationId: json['conversation_id'] as int,
        isGroup: json['is_group'] == 1,
        nameGroup: json['name_group'] as String?,
        lastMessage: json['last_message'] as String? ?? '',
        lastMessageTime: json['last_message_time'] == null
            ? null
            : DateTime.parse(json['last_message_time']),
        friendUser: json['friend_user_name'] as String? ?? '',
        avatarUrl: json['url'] as String?  ?? '',
        unreadCount: json['unread_count'] as int? ?? 0, // 👈 Thêm từ JSON
        member: json['member_count'] as int? ?? 2, // 👈 Thêm từ JSON
        replyTo: json['reply_to'] as int? ?? 0,
      );
    } catch (e) {
      print('❌ Error parsing ConversationModel: $e');
      return ConversationModel(
        conversationId: 0,
        isGroup: false,
        nameGroup: null,
        lastMessage: '',
        lastMessageTime: null,
        friendUser: '',
        avatarUrl: '',
        unreadCount: 0,
        member: 2, // Mặc định nếu có lỗi
        replyTo: 0
      );
    }
  }

  Conversation toEntity() {
    return Conversation(
      conversationId: conversationId,
      isGroup: isGroup,
      nameGroup: nameGroup,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      friendUserName: friendUser,
      avatarUrl: avatarUrl,
      unreadCount: unreadCount, // 👈 Gửi qua entity nếu cần
      member: member, // 👈 Gửi qua entity nếu cần
      replyTo: replyTo
    );
  }
}
