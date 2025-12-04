import '../repositories/social_repository.dart';

class LikePostUseCase {
  final SocialRepository repository;

  LikePostUseCase(this.repository);

  Future<bool> call(int postId) {
    return repository.likePost(postId);
  }
}