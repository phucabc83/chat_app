import 'dart:typed_data';

import 'package:chat_app/features/social/domain/entities/comment.dart';

import '../entities/post.dart';

abstract class SocialRepository {
  Future<List<Post>> fetchPosts();

  Future<Post> createPost(
      {required String content, Uint8List? fileBytes, String? fileNameImage, String? mimeType});

  Future<void> deletePost(String id);

  Future<bool> likePost(int postId);

  Future<Comment> commentOnPost(int postId, String content);

  Future<List<Comment>> fetchComments({required int postId});

  Future<List<Post>> fetchUserPosts({required int userId});


}