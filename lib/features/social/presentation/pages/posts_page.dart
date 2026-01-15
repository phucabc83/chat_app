import 'package:chat_app/features/social/presentation/blocs/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/router_app_name.dart';
import '../../../../core/theme/theme_app.dart';
import '../../domain/entities/post.dart';
import 'package:chat_app/features/social/presentation/widgets/post_item.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {


  @override
  void initState() {
    context.read<PostsCubit>().loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('Social Posts',style: theme.textTheme.titleLarge)
        ),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<PostsCubit,PostsState>(
          builder: (context, state) {

            print('posts state: $state');
            if(state.loading){
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );

              }

            if(state.posts.isEmpty){
              return Center(
                child: Text('Không có bài post',style: theme.textTheme.bodyMedium),
              );
            }



              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: state.posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostItem(post: post);
                },
              );
          }
        ),
        floatingActionButton:FloatingActionButton(
          onPressed: () => context.pushNamed(AppRouteInfor.createPostName),
          heroTag: null,
          backgroundColor: Colors.blueAccent,
          shape: CircleBorder(),
          child: const Icon(Icons.add,color: Colors.white,),

        )
      ),
    );
  }
}
