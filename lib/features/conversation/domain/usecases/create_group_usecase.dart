import '../repositories/group_repository.dart';

class CreateGroupUseCase{
  final GroupRepository createGroupRepository;

  CreateGroupUseCase(this.createGroupRepository);

  Future<void> call(String groupName, String groupDescription,int avatar,List<int> member) async {
    return await createGroupRepository.insertGroup(groupName, groupDescription,avatar,member);
  }
}