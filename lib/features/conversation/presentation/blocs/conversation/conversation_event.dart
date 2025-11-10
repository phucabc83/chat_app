import 'package:chat_app/features/conversation/domain/entities/conversation.dart';

import '../../../../auth/domain/entities/user.dart';

abstract class ConversationEvent {}
abstract class StatusUsersEvent {}


class AllConversationLoadEvent extends ConversationEvent {
  AllConversationLoadEvent();
}

 class LoadStatusFriendsEvent extends StatusUsersEvent{

}

class UpdateOnlineFriendEvent extends StatusUsersEvent{
  final User user;
  final bool isOnline;

  UpdateOnlineFriendEvent(this.user, this.isOnline);
}

class ReceiveInComingCallEvent extends ConversationEvent{

  final String usernameCaller;
  final String avatarUrlCaller;
  final int callerID;
  final int callID;
  ReceiveInComingCallEvent({
    required this.usernameCaller,
    required this.avatarUrlCaller,
    required this.callerID,
    required this.callID,
  });
}



class GetListFriendsOnlineEvent extends StatusUsersEvent{
  final List<User> users;
  GetListFriendsOnlineEvent(this.users);
}




