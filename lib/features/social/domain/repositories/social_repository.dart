import '../entities/post.dart';

abstract class SocialRepository {
  Future<List<Post>> fetchPosts();
  Future<Post> createPost({required String content, String? imageUrl});
  Future<void> deletePost(String id);
}

