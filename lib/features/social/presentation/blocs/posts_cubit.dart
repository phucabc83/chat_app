
import 'package:chat_app/core/permissions/permission_service.dart';
import 'package:chat_app/core/service/image_picker_service.dart';
import 'package:chat_app/core/service/socket_service.dart';
import 'package:chat_app/features/social/data/models/comment_model.dart';
import 'package:chat_app/features/social/domain/usecases/like_post_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/usecases/fetch_post_user_usecase.dart';
import '../../domain/usecases/fetch_posts_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';


class PostsCubit extends Cubit<PostsState> {
  final FetchPostsUseCase fetchPostsUseCase;
  final LikePostUseCase likePostUseCase;
  final SocketService socketService;
  final FetchPostUserUsecase fetchPostUserUsecase;




  PostsCubit({
    required this.fetchPostsUseCase,
    required this.likePostUseCase,
    required this.socketService,
    required this.fetchPostUserUsecase,
  }) : super(const PostsState());

  Future<void> loadPosts() async {
    try {

      debugPrint('🟢 [PostsCubit] Loading posts...');
      emit(state.copyWith(loading: true, error: null));



      final posts = await fetchPostsUseCase.execute();
      print('data load posts: $posts');

      emit(state.copyWith(loading: false, posts: posts));
      socketService.listenUpdatePost(_onPostUpdated);
      socketService.listenNewLike((data) {
        final postId = data['postId'];
        print('data like post: $postId ${postId.runtimeType}');
        print('data current posts: ${state.posts}');
        final index = state.posts.indexWhere((post) => int.parse(postId) == post.id);
        if (index != -1) {
          print('Post found. Updating like count...');
           final update = state.posts[index];
          final updatedPost = update.copyWith(likes: update.likeCount + 1, isLiked: true);

          final updatedPosts = List<Post>.from(state.posts);
          updatedPosts[index] = updatedPost;

          emit(state.copyWith(posts: updatedPosts));
        }

      });
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }


  Future<void> loadPostForUser(int userId) async {
    try {

      debugPrint('🟢 [PostsCubit] Loading posts user ...');
      emit(state.copyWith(loading: true, error: null));



      final posts = await fetchPostUserUsecase.call(userId);
      print('data load posts user : $posts');

      emit(state.copyWith(loading: false, posts: posts));

    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }




  Future<void> likePost(int postId) async {
    try {
      await  likePostUseCase.call(postId);


    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onPostUpdated(Post post) {
    emit(state.copyWith(loading: true));
    state.posts.insert(0,post);
    final List<Post> posts = List.from(state.posts);
    emit(state.copyWith(posts: posts,loading: false));
  }








}
class PostsState extends Equatable {
  final bool loading;
  final bool submitting;
  final List<Post> posts;
  final String? error;

  const PostsState({
    this.loading = false,
    this.submitting = false,
    this.posts = const [],
    this.error
  });

  PostsState copyWith({
    bool? loading,
    bool? submitting,
    List<Post>? posts,
    String? error,
  }) {
    return PostsState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      posts: posts ?? this.posts,
      error: error ?? this.error
    );
  }

  @override
  List<Object?> get props => [loading, submitting, posts, error];
}

