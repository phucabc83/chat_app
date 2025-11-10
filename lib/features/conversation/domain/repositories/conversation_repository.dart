
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';

abstract class ConversationRepository{
  Future<List<Conversation>> getConversations(bool isGroup);
}