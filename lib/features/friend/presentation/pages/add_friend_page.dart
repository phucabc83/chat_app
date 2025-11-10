import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/friend_bloc.dart';
import '../blocs/friend_event.dart';
import '../blocs/friend_state.dart';
import '../widgets/user_search_item.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();

  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      context.read<FriendBloc>().add(SearchUsers(query));
    } else {
      context.read<FriendBloc>().add(ClearSearch());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF18202D),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(

              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by name ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<FriendBloc>().add(ClearSearch());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: theme.textTheme.bodyMedium,

              ),
            ),
          ),
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
          } else if (state is FriendRequestSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FriendLoaded) {
            if (!state.isSearching) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Search for users to add as friends',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.searchResults.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.searchResults.length,
              itemBuilder: (context, index) {
                final user = state.searchResults[index];
                return UserSearchItem(
                  user: user,
                  onSendRequest: (userId, message) {
                    context.read<FriendBloc>().add(
                      SendFriendRequest(
                        receiverId: userId,
                        message: message,
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
