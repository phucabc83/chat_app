import 'dart:typed_data';

import 'package:chat_app/features/social/data/models/comment_model.dart';
import 'package:chat_app/features/social/data/models/post_model.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/social_repository.dart';
import '../data_sources/social_remote_data_source.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Post>> fetchPosts() async {
    final models = await remoteDataSource.fetchPosts();
    return models.map<Post>((model) => model.toEntity()).toList();
  }

  @override
  Future<Post> createPost({required String content, Uint8List? fileBytes,String? fileNameImage,String? mimeType}) async {
    final model = await remoteDataSource.createPost(
      content: content,
      fileBytes: fileBytes,
      fileNameImage: fileNameImage,
      mimeType: mimeType,
    );
    return PostModel.fromEntity(model);
  }

  @override
  Future<void> deletePost(String id) async {
    await remoteDataSource.deletePost(id);
  }

  @override
  Future<bool> likePost(int postId) async {
      return await remoteDataSource.likePost(postId);
  }

  @override
  Future<Comment> commentOnPost(int postId, String content) async{
    final commentModel = await remoteDataSource.commentPost(postId, content);
      return commentModel.toEntity() ;
  }

  @override
  Future<List<Comment>> fetchComments({required int postId}) async{
        final comments =  await remoteDataSource.fetchComments(postId: postId);
        comments.map<Comment>((e) => e.toEntity()).toList();
        return comments;
  }


  @override
  Future<List<Post>> fetchUserPosts({required int userId}) {
      return remoteDataSource.fetchPostUser(userId).then((models) => models.map<Post>((model) => model.toEntity()).toList());
  }

}
