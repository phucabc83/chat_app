import '../entities/comment.dart';
import '../entities/post.dart';
import '../repositories/social_repository.dart';

class FetchCommentsUsecase {
  final SocialRepository repository;

  FetchCommentsUsecase(this.repository);

  Future<List<Comment>> call(int postId) async {
    return await repository.fetchComments(postId:postId);
  }
}

