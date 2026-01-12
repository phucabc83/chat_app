import 'package:chat_app/features/social/domain/entities/post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(name: '', avatarUrl: ''));
}

class ProfileState {
  String name;
  String avatarUrl;
  bool isLoading;
  List<Post> posts;
  int get postCount => posts.length;
  bool isFriend ;
  int friendCount = 0;

  ProfileState({
    required this.name,
    required this.avatarUrl,
    this.isLoading = false,
    this.isFriend =false,
    this.posts = const [],
  });

  ProfileState copyWith({
    String? name,
    String? avatarUrl,
    bool? isLoading,
    List<Post>? posts,
    bool? isFriend,
  }) {
    return ProfileState(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      isFriend : isFriend ?? this.isFriend
    );
  }

}