import 'dart:async';
import 'dart:io';

import 'package:chat_app/core/service/image_picker_service.dart';
import 'package:chat_app/core/service/supabase_storage_service.dart';
import 'package:chat_app/features/chat/domain/entities/messsage.dart';
import 'package:chat_app/features/chat/domain/usecases/load_message_usecase.dart';
import 'package:chat_app/features/chat/presentation/blocs/chat_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../core/service/image_compressor.dart';
import '../../../../core/service/socket_service.dart';
import '../../../../core/utils/util.dart';
import '../pages/chat_page/chat_page.dart';
import 'chat_state.dart';

extension PagingControllerChatOps
    on PagingController<RequestMessage?, Message> {
  /// Thêm message mới lên đầu trang đầu tiên (optimistic insert)
  void prependMessage(Message m) {
    final s = value;
    final pages = (s.pages ?? const []).map<List<Message>>((p) => List<Message>.from(p.cast<Message>())).toList();
    if (pages.isEmpty) {
      pages.add([m]);
    } else {
      final firstPage = List<Message>.from(pages.first);
      if (!firstPage.any((x) => x.id == m.id)) {
        firstPage.insert(0, m);
      }
      pages[0] = firstPage;
    }
    value = s.copyWith(pages: pages);
  }

  /// Tăng readCount cho TẤT CẢ tin nhắn do currentUser gửi, có id <= upTo
  /// (mỗi event +1, không vượt quá totalRecipients)
  void incrementReadUpTo({required int upTo, required int currentUserId}) {
    final s = value;
    final pages = (s.pages ?? const []).map<List<Message>>((p) => List<Message>.from(p.cast<Message>())).toList();
    var changed = false;

    for (var p = 0; p < pages.length; p++) {
      final page = List<Message>.from(pages[p]);
      for (var i = 0; i < page.length; i++) {
        final m = page[i];
        if (m.id <= upTo &&
            m.senderId == currentUserId &&
            m.readCount < m.totalRecipients) {
          page[i] = m.copyWith(readCount: m.readCount + 1);
          changed = true;
        }
      }
      pages[p] = page;
    }

    if (changed) value = s.copyWith(pages: pages);
  }

  /// Tăng deliveredCount cho message có id == messageId
  /// (mỗi event +1, không vượt quá totalRecipients)
  void incrementDeliveredById(int messageId) {
    final s = value;
    final pages = (s.pages ?? const []).map<List<Message>>((p) => List<Message>.from(p.cast<Message>())).toList();
    var changed = false;

    for (var p = 0; p < pages.length; p++) {
      final page = List<Message>.from(pages[p]);
      for (var i = 0; i < page.length; i++) {
        final m = page[i];
        if (m.id == messageId && m.deliveredCount < m.totalRecipients) {
          page[i] = m.copyWith(deliveredCount: m.deliveredCount + 1);
          pages[p] = page;
          changed = true;
        }
      }
    }

    if (changed) value = s.copyWith(pages: pages);
  }
}

class ChatBloc extends Bloc<ChatEvent, StateUI> {
  final LoadMessageUseCase loadMessageUseCase;
  final SocketService socketService = SocketService();
  final List<Message> messages = [];
  bool initialLoad = true;
  Map<String, dynamic>? _lastNextCursor;
  bool _lastHasMore = true;
  late PagingController<RequestMessage?, Message> pagingController;

  final ImagePickerService imagePickerService;
  final SupabaseStorageService supabaseStorageService;

  ChatBloc(
    {required this.loadMessageUseCase,
    required this.imagePickerService,
    required this.supabaseStorageService}
  ) : super(Initial()) {
    debugPrint('[ChatBloc] constructor');
    on<MarkMessageReadEvent>(_markMessageRead);
    on<MessageSendEvent>(_sendMessage);
    initPagingController();
    on<SendImageMessage>(_sendImageMessage);

  }

  Future<void> setConversation(int id, int replyTo, bool isGroup) async {
    state.replyTo = replyTo;
    state.isGroup = isGroup;
    if (id == 0) {
      id = await loadMessageUseCase.callConversationId(state.replyTo);
      state.conversationId = id;
      pagingController.refresh();
    }
    state.conversationId = id;

    print(pagingController.toString());
  }

  FutureOr<void> _sendMessage(
    MessageSendEvent event,
    Emitter<StateUI> emit,
  ) async {
    if (state.conversationId == 0) return;
    try {
      final message = await socketService.sendMessage(
        conversationId: state.conversationId,
        content: event.content,
        senderId: Util.userId,
        messageType: event.messageType,
        senderName: Util.userName,
        replyTo: event.replyTo,
        isGroup: event.isGroup,
      );

      messages.add(message);
      pagingController.prependMessage(message);

    } catch (e) {
      emit(Failture(e.toString()));
    }
  }

  FutureOr<void> _markMessageRead(
    MarkMessageReadEvent event,
    Emitter<StateUI> emit,
  ) {
    debugPrint('[ChatBloc] _markMessageRead');
    socketService.markMessageRead(
      conversationId: event.conversationId,
      userId: event.userId,
      maxMessageId: event.messageId,
    );
  }

  void _receiveMessage(Message message) {
    print('start receive message');

    pagingController.prependMessage(message);
    messages.add(message);

    add(
      MarkMessageReadEvent(
        userId: Util.userId,
        conversationId: message.conversationId,
        messageId: message.id,
      ),
    );
  }

  void dispose(int conversationId, bool isGroup) {
    messages.clear();
    socketService.leaveConversation(state.conversationId, isGroup);
    socketService.offReceiveMessage(isGroup);
    socketService.offReadedMessage();
    socketService.offDeliveredMessage();
    pagingController.dispose();
  }

  Future<List<Message>> _fetchPage(RequestMessage? pageKey) async {
    var conversationId = state.conversationId;
    debugPrint('[fetchPage]  conversationId=${state.conversationId}');

    if (conversationId == 0) {
      return [];
    }
    try {
      final data = await loadMessageUseCase.call(conversationId, pageKey);
      messages.clear();
      messages.addAll(data.items);
      if(data.items.isEmpty){
        return [];
      }

      if(state.replyTo == 0){
        for(int i =0; i< data.items.length;i++){
          final msg = data.items[i];
          if(msg.senderId != Util.userId){
            state.replyTo = msg.senderId;
            break;
          }
        }
      }


      if (initialLoad) {
        socketService.joinConversation(conversationId, state.isGroup);
        socketService.receiveMessageByPrivateOrGroup(
          _receiveMessage,
          state.isGroup,
        );
        socketService.listenReceiptUpdates(_onDeliveredMessage);
        socketService.onReadedMessage(_onReadedMessage);

        debugPrint(
          ' initial : ${data.items.first.senderId} - ${Util.userId} - ${data.items.first.readCount}',
        );

        if (data.items.isNotEmpty &&
            data.items.first.senderId != Util.userId &&
            data.items.first.readCount == 0) {
          socketService.markMessageRead(
            conversationId: conversationId,
            userId: Util.userId,
            maxMessageId: messages.first.id,
          );
        }
      }

      if (initialLoad) {
        initialLoad = false;
      }
      _lastHasMore = data.hasMore;
      _lastNextCursor = data.nextCursor;
      print('_lastHasMore: $_lastHasMore, _lastNextCursor: $_lastNextCursor');


      return data.items;
    } catch (e) {
      return [];
    }
  }

  void _onReadedMessage({
    int? conversationId,
    required int messageId,
    required String type,
    int? upTo,
    required int userId,
  }) {
    debugPrint('[ChatBloc] _onReadedMessage');
    debugPrint(
      '  conversationId=$conversationId, messageId=$messageId, type=$type, upTo=$upTo, userId=$userId',
    );
    if (type != 'read' || upTo == null) return;

    pagingController.incrementReadUpTo(upTo: upTo, currentUserId: Util.userId);

    // (tuỳ chọn) nếu vẫn cần giữ List<Message> nội bộ đồng bộ:
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.id <= upTo &&
          m.senderId == Util.userId &&
          m.readCount < m.totalRecipients) {
        messages[i] = m.copyWith(readCount: m.readCount + 1);
      }
    }
  }

  void _onDeliveredMessage({
    int? conversationId,
    required int messageId,
    required String type,
    int? upTo,
    required int userId,
  }) {
    if (type != 'delivered') return;

    pagingController.incrementDeliveredById(messageId);

    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final msg = messages[idx];
      if (msg.deliveredCount < msg.totalRecipients) {
        messages[idx] = msg.copyWith(deliveredCount: msg.deliveredCount + 1);
      }
    }
  }

  void initPagingController() {
    pagingController = PagingController<RequestMessage?, Message>(
      getNextPageKey: (statePaging) {
        print('statePaging: $statePaging');

        final noPageYet =
            statePaging.pages == null || (statePaging.pages?.isEmpty ?? true);
        if (noPageYet) {
          return RequestMessage(
            conversationId: state.conversationId!,
            lastMessageId: null,
            createdAt: null,
          );
        }

        if (!_lastHasMore || _lastNextCursor == null) {
          return null;
        }

        print('[getNextPageKey] $_lastNextCursor');

        return RequestMessage(
          conversationId: state.conversationId!,
          lastMessageId: _lastNextCursor?['id'],
          createdAt: _lastNextCursor?['sent_at'],
        );
      },
      fetchPage: _fetchPage,
    );
  }
  //
  FutureOr<void> _sendImageMessage(
    SendImageMessage event,
    Emitter<StateUI> emit,
  ) async {
    final imagePick = await imagePickerService.pickImage();
    if (imagePick == null) return;
    Uint8List inputBytes;

    final fileName = imagePick['fileName'];

    if (fileName == null) return;

    if (kIsWeb) {
      final fileBytes = imagePick['fileBytes'];
      if (fileBytes == null) return;
      inputBytes = fileBytes;
    } else {
      final filePath = imagePick['filePath'];
      if (filePath == null) return;
      inputBytes = await File(filePath!).readAsBytes();
    }

    // 2) Compress (ví dụ mục tiêu ~80KB, khung 1080p, auto format)
    final out = await ImageCompressor.compressBytes(
      inputBytes,
      options: const ImageCompressOptions(
        targetKB: 80,
        maxWidth: 1080,
        maxHeight: 1080,
        startQuality: 85,
        minQuality: 40,
        format: OutputFormat.auto, // PNG nếu có alpha, JPEG nếu không
      ),
    );

    // 3) Gợi ý tên file & upload
    final newName = ImageCompressor.suggestFileName(fileName, out);


    final message = await socketService.sendMessage(
      conversationId: state.conversationId,
      content: event.content,
      senderId: Util.userId,
      messageType: event.messageType,
      senderName: Util.userName,
      replyTo: event.replyTo,
      isGroup: event.isGroup,
      fileNameImage: newName,
      bytesImage: out.bytes,
      mimeType: out.mimeType
    );


    messages.add(message);

    pagingController.prependMessage(message);




  }
}
