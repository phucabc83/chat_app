import '../../domain/entities/post.dart';
import '../../domain/repositories/social_repository.dart';
import '../data_sources/social_remote_data_source.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Post>> fetchPosts() async {
    final models = await remoteDataSource.fetchPosts();
    return models.map<Post>((m) => m).toList();
  }

  @override
  Future<Post> createPost({required String content, String? imageUrl}) async {
    final model = await remoteDataSource.createPost(content: content, imageUrl: imageUrl);
    return model;
  }

  @override
  Future<void> deletePost(String id) async {
    await remoteDataSource.deletePost(id);
  }
}
