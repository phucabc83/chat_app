import '../entities/post.dart';
import '../repositories/social_repository.dart';

class CreatePostUseCase {
  final SocialRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> execute({required String content, String? imageUrl}) async {
    return await repository.createPost(content: content, imageUrl: imageUrl);
  }
}

