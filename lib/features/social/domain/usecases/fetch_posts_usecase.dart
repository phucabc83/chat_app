import '../entities/post.dart';
import '../repositories/social_repository.dart';

class FetchPostsUseCase {
  final SocialRepository repository;

  FetchPostsUseCase(this.repository);

  Future<List<Post>> execute() async {
    return await repository.fetchPosts();
  }
}

