import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String avatar;

  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.avatar
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] ?? '', // Optional token field
      avatar: json['avatar']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      token: token,
      avatar: avatar,
    );
  }
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email ?? '',
      token: user.token ?? '',
      avatar: user.avatar ?? '',
    );
  }
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email token: $token)';
  }
}