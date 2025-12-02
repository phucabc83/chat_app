import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorId, content, imageUrl, createdAt];
}

