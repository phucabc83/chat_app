import 'package:chat_app/core/service/api_service.dart';
import '../models/post_model.dart';

class SocialRemoteDataSource {
  final ApiService apiService;

  SocialRemoteDataSource({required this.apiService});

  Future<List<PostModel>> fetchPosts() async {
    final res = await apiService.dio.get('/posts');
    final data = res.data as List<dynamic>;
    return data.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PostModel> createPost({required String content, String? imageUrl}) async {
    final body = {'content': content, 'imageUrl': imageUrl};
    final res = await apiService.dio.post('/posts', data: body);
    return PostModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) async {
    await apiService.dio.delete('/posts/$id');
  }
}

