import 'package:chat_app/features/conversation/domain/entities/avatar.dart';

import '../entities/conversation.dart';

abstract class GroupRepository {
  Future<void> insertGroup(String groupName, String groupDescription,int avatarId,List<int> member);
  Future<List<Avatar>> getAllAvatars();
  Future<List<Avatar>> getAllUserAvatars();


  Future<List<Conversation>> getGroupsByUserId(int userId);
}