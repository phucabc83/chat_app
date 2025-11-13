
import 'package:chat_app/core/service/audio_manage.dart';
import 'package:chat_app/core/service/socket_service.dart';

import 'package:chat_app/features/chat/domain/entities/messsage.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversation_usecase.dart';
import 'package:chat_app/features/conversation/presentation/blocs/conversation/conversation_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/utils/util.dart';
import '../../../../auth/domain/entities/user.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState>{
  final FetchAllConversationUsecase _fetchAllConversationUsecase;
  final SocketService _socketService = SocketService();

  final _storage = const FlutterSecureStorage();
  List<Conversation> conversations = [];
  List<User> usersOnline = [];


  ConversationBloc(this._fetchAllConversationUsecase):super(ConversationInitial()){

    on<AllConversationLoadEvent>((event, emit) async {
      emit(ConversationLoading());
      try {
        final data = await _fetchAllConversationUsecase.call();
        conversations.clear();
        conversations.addAll(data);
        emit(ConversationSuccess(conversations));
        _socketService.conversationReceiveMessage(_receiveMessage, false);
      } on DioException catch (e) {
        if (e.response != null) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            await _storage.delete(key: 'token');
            await _storage.delete(key: 'userId');
            Util.userId = 0;
            Util.token = '';
            emit(ConversationFailure('Unauthorized, please login again'));
          } else {
            emit(ConversationFailure(
                e.response?.data['message'] ?? 'Server error'));
          }

        } else {
          // Lỗi không có response (timeout, không có mạng, ...)
          emit(ConversationFailure(e.message ?? 'Unknown error'));
        }

        print('Error Responeee: ${e.response}');

      }
      catch (e ) {

        print('Error Responeee2: ${e.runtimeType}');

        emit(ConversationFailure(e.toString()));
      }
    }
    );

  }
  

  void _receiveMessage(Message message) {
      final conversation =  conversations.firstWhere(
           (m) => m.conversationId == message.conversationId
       );

      conversation.lastMessage = message.content;
      conversation.lastMessageTime = message.sentAt;
      if(message.senderId != Util.userId  && message.readCount < message.totalRecipients &&
          message.deliveredCount < message.totalRecipients ) {
        conversation.unreadCount += 1;
      }

      if(message.senderId != Util.userId){
        AudioManager().playAsset('message_audio.mp3',isLoop: false);
      }
      emit(ConversationSuccess<List<Conversation>>(List.from(conversations)));
  }



  void _onUpdate({int? conversationId, required int messageId,
    required String type, int? upTo, required int userId}) {
    if (type != 'delivered') return;


    }

  }

