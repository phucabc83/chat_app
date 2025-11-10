import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/router_app_name.dart';
import '../../../../core/theme/theme_app.dart';
import '../../domain/entities/friend.dart';
import '../blocs/friend_bloc.dart';
import '../blocs/friend_event.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({
    super.key,
    required this.friend,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: DefaultColors.messageListPage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: friend.avatar != null
                  ? NetworkImage(friend.avatar!)
                  : null,
              child: friend.avatar == null
                  ? Text(
                      friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (friend.status.toLowerCase() != 'offline')
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _getStatusColor(friend.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend.name,
          style: theme.textTheme.bodyMedium,

        ),
        // subtitle: Padding(
        //   padding: EdgeInsets.only(top: 8),
        //   child: Text(
        //     friend.status.toLowerCase() == 'offline'
        //         ? 'Last seen ${_getLastSeenText(friend.lastSeen)}'
        //         : friend.status.toUpperCase(),
        //     style: theme.textTheme.bodyMedium
        //   ),
        // ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'message':
                context.pushNamed(AppRouteInfor.chatName,
                    queryParameters: {
                      'name': friend.name,
                      'isGroup': 'false',
                      'id':'0',
                      'avatar': friend.avatar,
                      'member': '2',
                      'replyTo': friend.id.toString()
                    },
                 pathParameters: {
                  'id': 0.toString()
                }
                );
                break;
              case 'profile':

                break;
              case 'remove':
                _showRemoveDialog(context);
                break;
              case 'block':
                _showBlockDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'message',
              child: Row(
                children: [
                  Icon(Icons.message),
                  SizedBox(width: 8),
                  Text('Message'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove Friend', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Block', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to chat or profile
        },
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.name} from your friends?',style:Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FriendBloc>().add(RemoveFriend(friend.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
        backgroundColor: DefaultColors.buttonColor,
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${friend.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FriendBloc>().add(BlockFriend(friend.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
