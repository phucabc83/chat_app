import '../../domain/entities/post.dart';

class PostModel extends Post {


  const PostModel({
    required super.id,
    required super.authorId,
    required super.content,
    required super.createdAt,
    super.imageUrl,
    super.visibility = 'public',
    required super.username,
    required super.avatarUrl,
  });


  factory PostModel.fromJson(Map<String, dynamic> json) {
    try{
      return PostModel(
        id: json['id'].toString(),
        authorId: json['author_id'].toString(),
        content: json['content'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        visibility: json['visibility'] as String? ?? 'public',
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
          username: json['name'] as String? ?? 'Unknown',
          avatarUrl: json['avatar_url'] as String? ?? '',
      );
    }catch(e){
      throw Exception('Error parsing PostModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'imageUrl': imageUrl,
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  factory PostModel.fromEntity(Post post) {
    try{
      return PostModel(
        id: post.id,
        authorId: post.authorId,
        content: post.content,
        imageUrl: post.imageUrl,
        visibility: post.visibility,
        createdAt: post.createdAt,
        username: post.username,
        avatarUrl: post.avatarUrl,
      );
    }catch(e){
      throw Exception('Error converting Post to PostModel: $e');
    }
  }

}
