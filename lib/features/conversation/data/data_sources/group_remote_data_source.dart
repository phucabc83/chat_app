import 'package:chat_app/core/service/api_service.dart';
import 'package:chat_app/features/conversation/data/models/avatar_model.dart';
import 'package:chat_app/features/conversation/data/models/conversation_model.dart';
import 'package:chat_app/features/conversation/domain/entities/avatar.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';

class GroupRemoteDataSource{
  final ApiService apiService;
  GroupRemoteDataSource({
    required this.apiService,
  });

  Future<List<AvatarModel>> getAllAvatars() async {
    try {
      final List<AvatarModel> avatars = await apiService.getAllAvatars();
      print('Fetched ${avatars.length} avatars');
      return avatars;
    } catch (e) {
      print('Error fetching avatars: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  Future<List<ConversationModel>> getGroups(int userId) async {
    try {
      final List<ConversationModel> groups = await apiService.getGroupConversationByUserId(userId);
      print('Fetched ${groups.length} groups');
      return groups;
    } catch (e) {
      print('Error fetching groups: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  Future<void> insertGroup(String groupName, String groupDescription, int avatarId,List<int> member) async {
    try {
      await apiService.insertGroup(groupName, groupDescription, avatarId, member);
      print('Group inserted successfully');
    } catch (e) {
      print('Error inserting group: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  Future<List<AvatarModel>> getAllUserAvatars() async{
    return await apiService.getAllUserAvatars().then((avatars) {
      print('Fetched ${avatars.length} user avatars');
      return avatars;
    }).catchError((e) {
      print('Error fetching user avatars: ${e.toString()}');
      throw Exception(e.toString());
    });
  }


}