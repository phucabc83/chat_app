import 'package:chat_app/features/social/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required int id,
    required int postId,
    required int authorId,
    required String content,
    required DateTime createdAt,
    required String authorName,
    required String authorAvatarUrl,
  }) : super(
         id: id,
         postId: postId,
         authorId: authorId,
         content: content,
         createdAt: createdAt,
          authorName: authorName,
          authorAvatarUrl: authorAvatarUrl,
       );

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    try{
      print('Parsing CommentModel from JSON: $json');
      return CommentModel(
        id: json['id'] ,
        postId: json['post_id'] ,
        authorId: json['author_id'] ,
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
        authorName: json['username'] ?? '',
        authorAvatarUrl: json['avatar_url'] ?? '',
      );
    }catch(e){
      throw Exception('Error parsing CommentModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'createAt': createdAt.toIso8601String(),
    };
  }

  Comment toEntity()  {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
    );
  }
}
