
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page/chat_page.dart';

import '../../../../core/service/api_service.dart';

class ChatRemoteDataSource {
  ApiService apiService;
  ChatRemoteDataSource({
    required this.apiService,
  });

  Future<PageResult<MessageModel>> fetchAllMessageByConversation(int conversationId, RequestMessage? requestMessage) async {
    try {
      final response = await apiService.fetchAllMessageByConversationId(conversationId, requestMessage);
      return PageResult(
          items: response.items,
          hasMore: response.hasMore,
          nextCursor: response.nextCursor
      );
    } catch (e) {
      print('Error fetching conversations_bloc.dart: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

 Future<int> getConversationId(int receiveId) async{
    return  apiService.getConversationsId(receiveId).then((value) {
      return value;
    });
  }

}