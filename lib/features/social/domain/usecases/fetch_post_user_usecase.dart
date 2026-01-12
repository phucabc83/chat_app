import 'package:chat_app/features/social/domain/entities/post.dart';
import 'package:chat_app/features/social/domain/repositories/social_repository.dart';

class FetchPostUserUsecase {
  final SocialRepository repository;
  FetchPostUserUsecase(this.repository);
  Future<List<Post>> call(int userId) async {
    return await repository.fetchUserPosts(userId: userId);
  }
}