import 'dart:typed_data';

import 'package:chat_app/core/service/api_service.dart';
import 'package:chat_app/features/social/data/models/comment_model.dart';
import 'package:chat_app/features/social/domain/entities/comment.dart';
import '../models/post_model.dart';

class SocialRemoteDataSource {
  final ApiService apiService;

  SocialRemoteDataSource({required this.apiService});

  Future<List<PostModel>> fetchPosts() async {
    final data = await apiService.getPosts();
    return data;
  }

  Future<PostModel> createPost({required String content, Uint8List? fileBytes,String? fileNameImage,String? mimeType}) async {
    final post = await apiService.createPost(
      content: content,
      fileBytes: fileBytes,
      fileNameImage: fileNameImage,
      mimeType: mimeType,
        );
    return post;
  }

  Future<void> deletePost(String id) async {
    await apiService.dio.delete('/posts/$id');
  }
  Future<bool> likePost(int postId) async {
    try {
      return await apiService.addLikeForPost(postId: postId);
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  Future<CommentModel> commentPost(int postId, String content) async {
    try {
      return await apiService.addCommentToPost(postId: postId, content: content);
    } catch (e) {
      print('Error commenting on post: $e');
      rethrow;
    }
  }

  Future<List<CommentModel>> fetchComments({required int postId}) async {
    try {
      final comments = await apiService.getCommentsForPost(postId: postId);
      return comments;
    } catch (e) {
      print('Error fetching comments: $e');
      rethrow;
    }
  }
}

