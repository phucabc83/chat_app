/*

    {
        "id": 7,
        "conversation_id": 100,
        "sender_id": 5,
        "sender_name": "phuc",
        "message_type": "text",
        "content": "Thì vậy đó ",
        "reply_to": 1,
        "sent_at": "2025-08-06T08:09:17.000Z"
    }
 */

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
}

extension MessageTypeExtension on MessageType {
  String get label {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'sound';
      case MessageType.file:
        return 'file';
      case MessageType.location:
        return 'location';
    }
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String? senderName;

  final MessageType messageType;
  final String content;
  final int? replyTo;

  final DateTime sentAt;

  // 📌 Các thuộc tính trạng thái
  final int deliveredCount;       // số người đã nhận
  final int readCount;            // số người đã đọc
  final int totalRecipients;      // tổng số người nhận


  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.content,
    this.replyTo,
    required this.sentAt,
    this.deliveredCount = 0,
    this.readCount = 0,
    this.totalRecipients = 0,

  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      messageType: MessageType.values.firstWhere(
            (e) => e.label == json['messageType'],
        orElse: () => MessageType.text,
      ),
      content: json['content'],
      replyTo: json['replyTo'],
      sentAt: DateTime.parse(json['sentAt']),

      deliveredCount: json['deliveredCount'] ?? 0,
      readCount: json['readCount'] ?? 0,
      totalRecipients: json['totalRecipients'] ?? 0,


    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'messageType': messageType.label,
      'content': content,
      'replyTo': replyTo,
      'sentAt': sentAt.toIso8601String(),
      'delivered_count': deliveredCount,
      'read_count': readCount,
      'total_recipients': totalRecipients,

    };
  }

  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? senderName,
    MessageType? messageType,
    String? content,
    int? replyTo,
    DateTime? sentAt,
    int? deliveredCount,
    int? readCount,
    int? totalRecipients,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      replyTo: replyTo ?? this.replyTo,
      sentAt: sentAt ?? this.sentAt,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      readCount: readCount ?? this.readCount,
      totalRecipients: totalRecipients ?? this.totalRecipients,
    );
  }

  String getStatus(bool isGroup) {
    if(isGroup){
      if(readCount > 0){
        return '$readCount người đã xem';
      }else if(deliveredCount > 0){
        return '$deliveredCount người đã nhận';

      }else{
        return 'đã gửi';
      }
    }else{
      if (readCount > 0) {
        return 'Đã xem';
      } else if (deliveredCount > 0) {
        return 'Đã nhận';
      } else {
        return 'Đã gửi';
      }
    }
  }
  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, senderId: $senderId, senderName: $senderName, messageType: $messageType, content: $content, replyTo: $replyTo, sentAt: $sentAt, deliveredCount: $deliveredCount, readCount: $readCount, totalRecipients: $totalRecipients}';
  }
}
