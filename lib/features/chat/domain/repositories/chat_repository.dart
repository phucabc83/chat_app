

import 'package:chat_app/features/chat/presentation/pages/chat_page/chat_page.dart';

import '../entities/messsage.dart';


class PageResult<T> {
  final List<T> items;
  final Map<String,dynamic>? nextCursor;
  final bool hasMore;
  const PageResult({required this.items, this.nextCursor, required this.hasMore});
}
abstract class ChatRepository {

  Future<PageResult<Message>> getAllMessagesByConversationId(int conversationId, RequestMessage? requestMessage);

  Future<int> getConversationId(int receiveId);

}