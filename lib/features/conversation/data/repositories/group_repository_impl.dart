import 'package:chat_app/features/conversation/domain/entities/avatar.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';

import '../../domain/repositories/group_repository.dart';
import '../data_sources/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Avatar>> getAllAvatars() async{
    final avatars = await remoteDataSource.getAllAvatars();
    return   avatars.map((avatar) => avatar.toEntity()).toList();
  }


  @override
  Future<void> insertGroup(String groupName, String groupDescription,int avatarId,List<int> member) async {
    return await remoteDataSource.insertGroup(groupName, groupDescription,avatarId,member);
  }

  @override
  Future<List<Conversation>> getGroupsByUserId(int userId) {
    return remoteDataSource.getGroups(userId).then((groups) {
      return groups.map((group) => group.toEntity()).toList();
    }).catchError((error) {
      throw Exception('Failed to fetch groups: $error');
    });
  }

  @override
  Future<List<Avatar>> getAllUserAvatars() {
    return remoteDataSource.getAllUserAvatars().then((avatars) {
      return avatars.map((avatar) => avatar.toEntity()).toList();
    }).catchError((error) {
      throw Exception('Failed to fetch user avatars: $error');
    });
  }




}