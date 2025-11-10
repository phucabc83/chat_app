import '../entities/avatar.dart';
import '../repositories/group_repository.dart';

class FetchAllAvatarsUseCase {
  final GroupRepository _groupRepository;

  FetchAllAvatarsUseCase(this._groupRepository);

  Future<List<Avatar>> call() async {
    return await _groupRepository.getAllAvatars();
  }
  Future<List<Avatar>> callUserAvatars() async {
    return await _groupRepository.getAllUserAvatars();
  }
}