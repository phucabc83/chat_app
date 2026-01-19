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
  final List<Conversation> _allConversations = [];

  final SocketService socketService = SocketService();
  final _storage = const FlutterSecureStorage();

  ConversationGroupCubit({required this.fetchConversationGroupUseCase}) : super(const ConversationGroupState());

  Future<void> loadConversationGroups() async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final data = await fetchConversationGroupUseCase.call(Util.userId);

      _allConversations
        ..clear()
        ..addAll(data);

      socketService.conversationReceiveMessage(_receiveMessage, true);

      emit(state.copyWith(
        loading: false,
        conversations: List.from(_allConversations),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
        conversations: [],
      ));
    }
  }

  void searchGroup(String keyword) {
    if (keyword.isEmpty) {
      emit(state.copyWith(
        conversations: List.from(_allConversations),
        keyword: '',
      ));
      return;
    }

    final filtered = _allConversations.where((c) {
      return c.nameGroup!
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();

    emit(state.copyWith(
      conversations: filtered,
      keyword: keyword,
    ));
  }




  void _receiveMessage(Message m) {
    final idx = _allConversations.indexWhere(
          (c) => c.conversationId == m.conversationId,
    );

    if (idx != -1) {
      final updatedConv = _allConversations[idx].copyWith(
        lastMessage: m.content,
        lastMessageTime: m.sentAt,
      );

      _allConversations[idx] = updatedConv;

      if (state.keyword.isNotEmpty) {
        searchGroup(state.keyword);
      } else {
        emit(state.copyWith(
          conversations: List.from(_allConversations),
        ));
      }
    }
  }


}

class ConversationGroupState extends Equatable {
  final bool loading;
  final List<Conversation> conversations;
  final String? error;
  final String keyword;

  const ConversationGroupState({
    this.conversations = const [],
    this.error,
    this.loading = false,
    this.keyword = '',
  });

  ConversationGroupState copyWith({
    List<Conversation>? conversations,
    String? error,
    bool? loading,
    String? keyword,
  }) {
    return ConversationGroupState(
      conversations: conversations ?? this.conversations,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  List<Object?> get props => [loading, conversations, error, keyword];
}
