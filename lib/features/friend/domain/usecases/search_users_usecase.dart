import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class SearchUsersUseCase {
  final FriendRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<Friend>> call(String query) async {
    if (query.trim().isEmpty) return [];
    return await repository.searchUsers(query);
  }
}
