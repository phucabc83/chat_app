import 'dart:typed_data';

import 'package:chat_app/core/service/api_service.dart';
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
}

