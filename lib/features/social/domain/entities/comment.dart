class Comment{
  final int id;
  final int postId;
  final int authorId;
  final String content;
  final DateTime createdAt;
  final String authorName;
  final String authorAvatarUrl;


  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.authorName,
    required this.authorAvatarUrl,
  });



}