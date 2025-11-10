import 'package:dio/dio.dart';

import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class FetchAllConversationUsecase{
  final ConversationRepository _conversationRepository;

  FetchAllConversationUsecase(this._conversationRepository);

  Future<List<Conversation>> call({isGroup = false}) async{
    try{
      final data = await _conversationRepository.getConversations(isGroup);
      return data;
    }catch(e){
      throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'Failed to load conversations. Please try again.'},
          )
      );
    }
  }
  Future<List<Conversation>> callByGroup({isGroup = true}) async{
    final data = await _conversationRepository.getConversations(isGroup);
    return data;
  }


}