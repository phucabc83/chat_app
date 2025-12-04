import '../repositories/social_repository.dart';

class DeletePostUseCase {
  final SocialRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> execute(String id) async {
    await repository.deletePost(id);
  }
}
