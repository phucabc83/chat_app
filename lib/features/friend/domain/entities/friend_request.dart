class FriendRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String senderName;
  final String senderEmail;
  final String? senderAvatar;
  final DateTime createdAt;
  final FriendRequestStatus status;
  final String? message;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderEmail,
    this.senderAvatar,
    required this.createdAt,
    required this.status,
    this.message,
  });

  FriendRequest copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? senderName,
    String? senderEmail,
    String? senderAvatar,
    DateTime? createdAt,
    FriendRequestStatus? status,
    String? message,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}
