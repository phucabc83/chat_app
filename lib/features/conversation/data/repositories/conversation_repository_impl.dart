import 'package:chat_app/features/conversation/domain/entities/conversation.dart';
import 'package:dio/dio.dart';

import '../../domain/repositories/conversation_repository.dart';
import '../data_sources/conversation_remote_data_source.dart';

class ConversationRepositoryImpl implements ConversationRepository  {
   final ConversationRemoteDataSource remoteDataSource;
  ConversationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Conversation>> getConversations(bool isGroup) async {
    // TODO: implement getConversations

    try{
      final conversationsModel = await remoteDataSource.getConversations(isGroup);
      return conversationsModel.map((e) => e.toEntity()).toList();
    } catch (e) {
      print('Error fetching conversations: ${e.toString()}');
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: e.toString(),
      );
    }

  }

}