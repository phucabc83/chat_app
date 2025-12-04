import 'package:chat_app/core/permissions/permission_service.dart';
import 'package:chat_app/core/service/image_picker_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/usecases/fetch_posts_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';


class PostsCubit extends Cubit<PostsState> {
  final FetchPostsUseCase fetchPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final PermissionService permissionService;
  final ImagePickerService imagePickerService;


  PostsCubit({
    required this.fetchPostsUseCase,
    required this.createPostUseCase,
    required this.deletePostUseCase,
    required this.permissionService,
    required this.imagePickerService,
  }) : super(const PostsState());

  Future<void> loadPosts() async {
    try {
      debugPrint('🟢 [PostsCubit] Loading posts...');
      emit(state.copyWith(loading: true, error: null));
      final posts = await fetchPostsUseCase.execute();
      print('data load posts: $posts');


      emit(state.copyWith(loading: false, posts: posts));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }



  Future<void> removePost(String id) async {
    try {
      await deletePostUseCase.execute(id);
      final updated = state.posts.where((p) => p.id != id).toList();
      emit(state.copyWith(posts: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  Future<void> chooseImage() async {
      var granted = await permissionService.requestPhotoPermission();
      if(!granted){
        state.copyWith(
          error: 'Storage permission denied.',
        );
      }
      final imageData = await imagePickerService.pickImage();

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

