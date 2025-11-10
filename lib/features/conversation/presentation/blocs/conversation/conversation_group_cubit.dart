import 'package:chat_app/core/service/socket_service.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/chat/domain/entities/messsage.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversation_group_usecase.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as _storage;

class ConversationGroupCubit extends Cubit<ConversationGroupState> {
  final FetchConversationGroupUseCase  fetchConversationGroupUseCase;
  final List<Conversation> conversations = [];
  final SocketService socketService = SocketService();
  final _storage = const FlutterSecureStorage();

  ConversationGroupCubit({required this.fetchConversationGroupUseCase}) : super(const ConversationGroupState());

  Future<void> loadConversationGroups() async {

    try{
      print('🟢 [ConversationGroupCubit] Loading conversation groups...');
      emit(state.copyWith(loading: true, error: null));
      conversations.clear();
      final data = await fetchConversationGroupUseCase.call(Util.userId);
      conversations.addAll(data);
      socketService.conversationReceiveMessage(_receiveMessage, true);
      emit(state.copyWith(loading: false, conversations: conversations, error: null));
    }on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        if(statusCode == 401 || statusCode == 403){
          await _storage.delete(key: 'token');
          await _storage.delete(key: 'userId');
          Util.userId = 0;
          Util.token = '';
          emit(state.copyWith(loading: false, error: 'Unauthorized. Please log in again.', conversations: []));
        }
        else {
          final errorMessage = e.response?.data['message'] ?? 'Failed to load conversations. Please try again.';
          emit(state.copyWith(loading: false, error: errorMessage, conversations: []));
        }
      }
    } catch(e){
      emit(state.copyWith(loading: false, error: e.toString(), conversations: []));
    }

  }



  void _receiveMessage(Message m) {
    final idx = conversations.indexWhere(
          (c) => c.conversationId == m.conversationId,
    );
    print('📥 [Socket] Conversation_update message: $m');


    if (idx != -1) {
      final updatedConv = conversations[idx].copyWith(
        lastMessage: m.content,
        lastMessageTime: m.sentAt,
      );

      final updatedList = [...conversations];
      updatedList[idx] = updatedConv;

      emit(state.copyWith(conversations: updatedList));
    }
  }

}

class ConversationGroupState extends Equatable {
  final bool loading;
  final List<Conversation> conversations;
  final String? error;
  const ConversationGroupState({
    this.conversations = const [],
    this.error,
    this.loading = false,
  });

  ConversationGroupState copyWith({
    List<Conversation>? conversations,
    String? error,
    bool? loading,
  }) {
    return ConversationGroupState(
      conversations: conversations ?? this.conversations,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
  @override
  List<Object?> get props => [loading, conversations, error];
  @override
  String toString() {
    return 'LoadUserState(loading: $loading, users: $conversations, error: $error)';
  }
}


