import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required String id,
    required String authorId,
    required String content,
    String? imageUrl,
    required DateTime createdAt,
  }) : super(
          id: id,
          authorId: authorId,
          content: content,
          imageUrl: imageUrl,
          createdAt: createdAt,
        );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),
      authorId: json['authorId'].toString(),
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

