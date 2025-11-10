
import 'package:chat_app/features/chat/domain/entities/messsage.dart';

abstract class ChatEvent {}

class MessageLoadEvent extends ChatEvent {
    /// Optional field to specify a message to reply to.fina
    final int conversationId;
    final replyTo;
    final bool isGroup; // Optional field to indicate if the conversation is a group chat
    final int? lastMessageId ;// Optional field to specify the last loaded message ID for pagination
    final int limit; // Optional field to specify the number of messages to load
    final String? createAt;
    MessageLoadEvent({required this.conversationId, required this.isGroup,
      this.replyTo = 0,this.lastMessageId,this.limit = 20,this.createAt });
}

class MessageSendEvent extends ChatEvent {
  final int conversationId;
  final String content;
  final MessageType messageType;
  final int? replyTo;// Nullable to handle cases where there is no reply
  final bool isGroup ; // Optional field to indicate if the message is in a group chat


  MessageSendEvent({
    required this.conversationId,
    required this.content,
    required this.messageType,
    this.replyTo,
    this.isGroup = false,
  });
}

class MessageDeleteEvent extends ChatEvent {
  final String conversationId;
  final int messageId;

  MessageDeleteEvent({
    required this.conversationId,
    required this.messageId,
  });
}

class MessageReceiveEvent extends  ChatEvent {
  final Message message;
  MessageReceiveEvent({required this.message});
}


class MarkMessageReadEvent extends ChatEvent {
  final int conversationId;
  final int messageId;
  final int userId;

  MarkMessageReadEvent( {
    required this.userId,
    required this.conversationId,
    required this.messageId,
  });


}

class SendImageMessage extends ChatEvent {
  final String imagePath;
  final int conversationId;
  final String content;
  final MessageType messageType;
  final int? replyTo;// Nullable to handle cases where there is no reply
  final bool isGroup ; // Optional field to indicate if the message is in a group chat


  SendImageMessage({
      required this.imagePath,
    required this.conversationId,
    required this.content,
    required this.messageType,
    this.replyTo,
    this.isGroup = false,
  });

}


class ReceiveVideoCallEvent extends ChatEvent {
  final int fromUserId;
  final String fromUsername;
  final String callID;
  final String fromUserAvatar;

  ReceiveVideoCallEvent({
    required this.fromUserId,
    required this.fromUsername,
    required this.callID,
    required this.fromUserAvatar,
  });
}