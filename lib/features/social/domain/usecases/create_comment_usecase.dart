import '../entities/comment.dart';
import '../repositories/social_repository.dart';

class CreateCommentUseCase {
  final SocialRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Comment> call(int postId, String comment) async{
    return await repository.commentOnPost(postId, comment);
  }
}