import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String authorId;
  final String username;
  final String content;
  final String? imageUrl;
  final String visibility;
  final String avatarUrl;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.visibility,
    required this.createdAt,
    required this.username,
    required this.avatarUrl
  });

  @override
  List<Object?> get props => [id, authorId, content, imageUrl, createdAt,username,avatarUrl];
}

