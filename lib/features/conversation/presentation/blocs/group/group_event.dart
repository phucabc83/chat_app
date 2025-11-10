abstract class GroupEvent {}

class InsertGroupEvent extends GroupEvent {
  final String groupName;
  final String groupDescription;
  final int avatarId;
  InsertGroupEvent(this.avatarId, {
    required this.groupName,
    required this.groupDescription,
  });
}

class LoadGroupsEvent extends GroupEvent {
  LoadGroupsEvent();
}

class LoadAllAvatarEvent extends GroupEvent {

}