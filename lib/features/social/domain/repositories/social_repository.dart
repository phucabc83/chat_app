import 'dart:typed_data';

import '../entities/post.dart';

abstract class SocialRepository {
  Future<List<Post>> fetchPosts();
  Future<Post> createPost({required String content, Uint8List? fileBytes,String? fileNameImage,String? mimeType});
  Future<void> deletePost(String id);
  Future<bool> likePost(int postId);
}

