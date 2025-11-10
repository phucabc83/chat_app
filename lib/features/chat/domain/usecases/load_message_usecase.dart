import 'package:chat_app/features/chat/domain/entities/messsage.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page/chat_page.dart';
import 'package:http/http.dart';

class LoadMessageUseCase {
  final ChatRepository _chatRepository;

  LoadMessageUseCase(this._chatRepository);

  Future<PageResult<Message>> call(int messageId,RequestMessage? requestMessage) async {
    return await _chatRepository.getAllMessagesByConversationId(messageId,requestMessage);
  }
  Future<int> callConversationId(int receiveId) async {
    final id = await _chatRepository.getConversationId(receiveId);
    return id;
  }
}