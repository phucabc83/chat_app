
import 'package:dio/dio.dart';

import '../../../../core/service/api_service.dart';
import '../models/conversation_model.dart';

class ConversationRemoteDataSource {
  ApiService apiService;
  ConversationRemoteDataSource({
    required this.apiService,
  });

  Future<List<ConversationModel>> getConversations(bool isGroup) async {
    try {
      final List<ConversationModel> conversations;
      if( isGroup) {
         conversations =  await apiService.getConversations(isGroup);
      } else {
          conversations =  await apiService.getConversations(isGroup);
      }
      print('Fetched ${conversations.length} conversations_bloc.dart');
      return conversations;


    } catch (e) {
      print('Error fetching conversations_bloc.dart: ${e.toString()}');
      throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString()
      );
    }
  }

}