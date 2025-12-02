import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/router_app_name.dart';
import '../../../../core/theme/theme_app.dart';
import '../../domain/entities/post.dart';
import 'package:chat_app/features/social/presentation/widgets/post_item.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  List<Post> _buildFakePosts() {
    final now = DateTime.now();
    return List.generate(8, (i) {
      return Post(
        id: 'post_$i',
        authorId: 'user_${i % 3}',
        content:
            'This is a fake post number ${i + 1}.\nIt shows how the UI will render a post with some sample text.',
        imageUrl: i % 3 == 0
            ? 'https://picsum.photos/seed/post$i/400/200'
            : null,
        createdAt: now.subtract(Duration(minutes: i * 5)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = _buildFakePosts();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('Social Posts',style: theme.textTheme.titleLarge)
        ),
        backgroundColor: Colors.transparent,
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostItem(post: post);
          },
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
