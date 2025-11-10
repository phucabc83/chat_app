class User {
  final int id;
  final String name;
  final String? email;
  final String? token;
  final String? avatar;
  final String? status;
  final DateTime? lastSeen;



  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.avatar,
    this.status,
    this.lastSeen,
  });

  User.basic({required this.id, required this.name,required this.avatar})
      : email = null,
        token = null,
        status = null,
        lastSeen = null;


  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, tọken: $token)';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      token: '',
      avatar: json['avatar'] as String?,
      status: json['status'] as String?,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }



}