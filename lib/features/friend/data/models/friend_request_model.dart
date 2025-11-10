import '../../domain/entities/friend_request.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.senderName,
    required super.senderEmail,
    super.senderAvatar,
    required super.createdAt,
    required super.status,
    super.message,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] ,
      senderId: json['senderId'] ,
      receiverId: json['receiverId'] as int,
      senderName: json['senderName'] as String,
      senderEmail: json['senderEmail'] as String,
      senderAvatar: json['senderAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'senderAvatar': senderAvatar,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'message': message,
    };
  }

  factory FriendRequestModel.fromEntity(FriendRequest request) {
    return FriendRequestModel(
      id: request.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      senderName: request.senderName,
      senderEmail: request.senderEmail,
      senderAvatar: request.senderAvatar,
      createdAt: request.createdAt,
      status: request.status,
      message: request.message,
    );
  }
}
