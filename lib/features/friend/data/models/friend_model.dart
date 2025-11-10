import '../../domain/entities/friend.dart';

class FriendModel extends Friend {
  const FriendModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    required super.status,
    required super.lastSeen,
    super.isBlocked,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['url'] as String?,
      status: json['status'] as String,
      lastSeen: DateTime.parse(json['last_seen'] as String),
      isBlocked: json['isBlocked'] == 0 ? false : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'status': status,
      'lastSeen': lastSeen.toIso8601String(),
      'isBlocked': isBlocked,
    };
  }

  factory FriendModel.fromEntity(Friend friend) {
    return FriendModel(
      id: friend.id,
      name: friend.name,
      email: friend.email,
      avatar: friend.avatar,
      status: friend.status,
      lastSeen: friend.lastSeen,
      isBlocked: friend.isBlocked,
    );
  }
}
