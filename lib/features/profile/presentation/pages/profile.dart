import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/friend/friend.dart';
import 'package:chat_app/features/social/presentation/blocs/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/router_app_name.dart';
import '../../../friend/presentation/blocs/friend_bloc.dart';
import '../../../friend/presentation/blocs/friend_state.dart';
import '../../../social/domain/entities/post.dart';
import '../../../social/presentation/widgets/post_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PostsCubit>().loadPostForUser(Util.userId);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(

        headerSliverBuilder: (context, _) =>
        [
          SliverToBoxAdapter(
            child: _buildProfileCard(context),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
                _buildTabBar()
            ),
          ),
        ],

        body: TabBarView(
          controller: _tabController,
          children: const [
            PostTab(),
            FriendTab(),
            ImageTab(),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileCard(BuildContext context) {
    final userName = Util.userName;
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  Util.avatarUrl ,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -40,
                left: 16,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                    NetworkImage('https://picsum.photos/200'),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          /// NAME
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              userName,
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// USERNAME
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '@johndoe',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          /// BIO
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tôi là lập trình viên yêu thích Flutter và Dart.',
              style: TextStyle(color: Colors.white),
            ),
          ),

          /// STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                      text: '5 ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Bạn bè   •   '),
                  TextSpan(
                      text: '10 ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Bài viết'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// BUTTONS
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ElevatedButton(
              onPressed: () {
          // _moveChatToDetail(context, friend)
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30)
      ),
      child: const Text('Nhắn tin', style: TextStyle(color: Colors.white)),
    ),
    const SizedBox(width: 12),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)
    ),
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30)
    ),
    onPressed: () {},
    child: const Text(
    'Thêm bạn bè',
    style: TextStyle(color: Colors.black),
    ),
    ),
    ],
    ),
    ],
    )
    ,
    )
    ,
    );
  }


  Widget _buildTabBar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white.withOpacity(0.2),
      elevation: 2,
      child: TabBar(

        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        dividerColor: Colors.transparent,

        tabs: const [
          Tab(text: 'Bài viết'),
          Tab(text: 'Bạn bè'),
          Tab(text: 'Ảnh'),
        ],
      ),
    );
  }

  _moveChatToDetail(BuildContext context, Friend friend) {
    context.pushNamed(AppRouteInfor.chatName,
        queryParameters: {
          'name': friend.name,
          'isGroup': 'false',
          'id': '0',
          'avatar': friend.avatar,
          'member': '2',
          'replyTo': friend.id.toString()
        },
        pathParameters: {
          'id': 0.toString()
        }
    );
  }
}


class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return tabBar;
  }

  @override
  bool shouldRebuild(_) => false;
}


class PostTab extends StatelessWidget {
  const PostTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.posts.isEmpty) {
          return const Center(
            child: Text(
              'Không có bài viết nào',
              style: TextStyle(color: Colors.white),
            ),
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
      },
    );
  }
}

class FriendTab extends StatelessWidget {
  const FriendTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FriendError) {
            return Center(
              child: Text(
                'Lỗi: ${state.message}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is FriendLoaded) {
            if (state.friends.isEmpty) {
              return const Center(
                child: Text(
                  'Không có bạn bè nào',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: state.friends.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return FriendListItem(friend: friend);
              },
            );
          }
          return const SizedBox.shrink();
        }
    );
  }

}

class ImageTab extends StatelessWidget {
  const ImageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.posts.isEmpty) {
          return const Center(
            child: Text(
              'Không có bài viết nào',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final posts = state.posts.where((post) =>
        post.imageUrl != null && post.imageUrl!.isNotEmpty)
            .toList();
        debugPrint('Filtered posts with images: ${posts.toString()}');

        return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: posts.length,
            itemBuilder: (_, i) =>
                Image.network(
                  posts[i].imageUrl!,
                  fit: BoxFit.cover,
                )
        );
      },
    );
  }


}
