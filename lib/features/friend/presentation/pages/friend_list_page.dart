import 'package:chat_app/core/routes/router_app_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/friend_bloc.dart';
import '../blocs/friend_event.dart';
import '../blocs/friend_state.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/friend_request_item.dart';
import 'add_friend_page.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FriendBloc>().add(LoadFriends());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Message',style: theme.textTheme.titleLarge),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add,color: Colors.white),
            onPressed: () {
              context.push(AppRouteInfor.addFriendPath);
            },
          ),
        ],
        bottom: TabBar(
          indicatorWeight:0,
          labelColor: Colors.white70,
          indicator: const UnderlineTabIndicator(borderSide: BorderSide.none),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: BlocConsumer<FriendBloc, FriendState>(
        listener: (context, state) {

          if (state is FriendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FriendRequestAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {

          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FriendLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Friends Tab
                state.friends.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Bạn chưa có bạn nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.friends.length,
                        itemBuilder: (context, index) {
                          final friend = state.friends[index];
                          return FriendListItem(friend: friend);
                        },
                      ),
                // Friend Requests Tab
                state.friendRequests.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No friend requests',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.friendRequests.length,
                        itemBuilder: (context, index) {
                          final request = state.friendRequests[index];
                          return FriendRequestItem(request: request);
                        },
                      ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
