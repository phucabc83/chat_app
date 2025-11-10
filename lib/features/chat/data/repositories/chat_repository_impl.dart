import 'package:chat_app/features/chat/domain/entities/messsage.dart';

import '../../domain/repositories/chat_repository.dart';
import '../../presentation/pages/chat_page/chat_page.dart';
import '../data_sources/chat_remote_data_source.dart';

 class ChatRepositoryImpl implements ChatRepository {
   final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<PageResult<Message>> getAllMessagesByConversationId(int conversationId,RequestMessage? requestMessage) async {
    try {
      final messagesModel = await remoteDataSource.fetchAllMessageByConversation(conversationId, requestMessage);
      return PageResult<Message>(
          items: messagesModel.items.map((e) => e.toEntity()).toList(),
          hasMore: messagesModel.hasMore,
          nextCursor: messagesModel.nextCursor
      );
    } catch (e) {
      print('Error fetching messages: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  @override
  Future<int> getConversationId(int receiveId) async{
    final id = await remoteDataSource.getConversationId(receiveId);
      return id;
  }


}