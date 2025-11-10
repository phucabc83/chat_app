import '../entities/conversation.dart';
import '../repositories/group_repository.dart';

class FetchConversationGroupUseCase {
  // This class is responsible for fetching conversation groups.
  // It will interact with the repository to get the data.

  final GroupRepository _repository;

  FetchConversationGroupUseCase(this._repository);

  Future<List<Conversation>> call(int userId) async {
    return await _repository.getGroupsByUserId(userId); // Assuming userId is 1 for now
  }
}