class Friend {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String status; // online, offline, busy
  final DateTime lastSeen;
  final bool isBlocked;

  const Friend({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.status,
    required this.lastSeen,
    this.isBlocked = false,
  });

  Friend copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? status,
    DateTime? lastSeen,
    bool? isBlocked,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  toJson() {}
}
