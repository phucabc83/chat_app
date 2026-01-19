// {
// "id": 7,
// "conversation_id": 100,
// "sender_id": 5,
// "sender_name": "phuc",
// "message_type": "text",
// "content": "Thì vậy đó ",
// "reply_to": 1,
// "sent_at": "2025-08-06T08:09:17.000Z"
// }

import 'package:chat_app/features/chat/domain/entities/messsage.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String messageType;
  final String content;
  final int? replyTo; // Nullable to handle cases where there is no reply
  final DateTime sentAt;
  final MessageStatus status; // Optional field for reply name

  // 📌 Các thuộc tính trạng thái
  final int deliveredCount;       // số người đã nhận
  final int readCount;            // số người đã đọc
  final int totalRecipients;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.content,
    this.replyTo,
    required this.sentAt,
    required this.status,
    required this.deliveredCount,
    required this.readCount,
    required this.totalRecipients
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String,
      messageType: json['message_type'] as String,
      content: json['content'] as String,
      replyTo: json['reply_to'] != null ? json['reply_to'] as int : null, // Handle nullable field
      sentAt: DateTime.parse(json['sent_at'] as String),
      status: MessageStatus.sent,
      deliveredCount: int.parse(json['delivered_count'] ),
      readCount: int.parse(json['read_count']) ,
      totalRecipients: json['total_recipients'] - 1?? 0, // Default to 0 if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message_type': messageType,
      'content': content,
      'reply_to': replyTo, // Nullable field
      'sent_at': sentAt.toIso8601String(),
    };
  }
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      messageType: getMessageTypeFromString(messageType),
      content: content,
      replyTo: replyTo,
      sentAt: sentAt,
      deliveredCount: deliveredCount,
      readCount: readCount,
      totalRecipients: totalRecipients,
    );
  }

  MessageType getMessageTypeFromString(String messageType) {
    switch (messageType) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'location':
        return MessageType.location;
      default:
        return MessageType.text; // Default to text if unknown type
    }
  }
}


/// 2 trạng thái: đã gửi / đã xem
enum MessageStatus { sent, seen }