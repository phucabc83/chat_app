import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/friend/friend.dart';
import 'package:chat_app/features/social/presentation/blocs/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/router_app_name.dart';
import '../../../../core/service/socket_service.dart';
import '../../../friend/presentation/blocs/friend_bloc.dart';
import '../../../friend/presentation/blocs/friend_state.dart';
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
    print(Util.avatarUrl);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey,
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );


    if (confirm != true) return;

    try {
      SocketService().logoutAndDisconnect();

      const storage = FlutterSecureStorage();
      await storage.delete(key: 'token');
      await storage.delete(key: 'userId');
      await storage.delete(key: 'userName');
      await storage.delete(key: 'avatarUrl');
      await storage.delete(key: 'fcmToken');

      Util.token = '';
      Util.userId = 0;
      Util.userName = '';
      Util.avatarUrl = '';
      Util.fcmToken = '';

      context.goNamed(AppRouteInfor.loginName);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildProfileCard(context)),

          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(_buildTabBar()),
          ),
        ],

        body: TabBarView(
          controller: _tabController,
          children: const [PostTab(), FriendTab(), ImageTab()],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final userName = Util.userName;
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    'https://picsum.photos/200',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 16,
                  child:CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade800,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: Util.avatarUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.white, size: 36),
                      ),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'tai@gmail.com',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tôi là một người yêu công nghệ và thích khám phá thế giới xung quanh.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white),
                  children: [

                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: BlocSelector<FriendBloc, FriendState, int>(
                        selector: (state) =>
                        state is FriendLoaded ? state.friends.length : 0,
                        builder: (context, friendCount) {
                          return Text(
                            '$friendCount ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),


                    const TextSpan(text: 'Bạn bè   •   '),

                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: BlocSelector<PostsCubit, PostsState, int>(
                        selector: (state) => state.posts.length,
                        builder: (context, postCount) {
                          return Text(
                            '$postCount ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),

                    const TextSpan(text: 'Bài viết'),
                  ],
                ),
              ),
            ),



            const SizedBox(height: 12),

            /// BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    context.pushNamed(
      AppRouteInfor.chatName,
      queryParameters: {
        'name': friend.name,
        'isGroup': 'false',
        'id': '0',
        'avatar': friend.avatar,
        'member': '2',
        'replyTo': friend.id.toString(),
      },
      pathParameters: {'id': 0.toString()},
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
          return const Center(child: CircularProgressIndicator());
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
      },
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
          return const Center(child: CircularProgressIndicator());
        }
        if (state.posts.isEmpty) {
          return const Center(
            child: Text(
              'Không có bài viết nào',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final posts = state.posts
            .where((post) => post.imageUrl != null && post.imageUrl!.isNotEmpty)
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
              Image.network(posts[i].imageUrl!, fit: BoxFit.cover),
        );
      },
    );
  }
}
