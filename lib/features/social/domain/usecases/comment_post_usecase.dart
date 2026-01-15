import 'package:chat_app/features/social/domain/entities/comment.dart';

import '../repositories/social_repository.dart';

class CommentPostUseCase {
  final SocialRepository repository;

  CommentPostUseCase(this.repository);

  Future<Comment> call(int postId, String comment) {
    return repository.commentOnPost(postId, comment);
  }
}