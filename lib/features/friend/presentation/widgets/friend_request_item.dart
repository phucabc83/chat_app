import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_app.dart';
import '../../domain/entities/friend_request.dart';
import '../blocs/friend_bloc.dart';
import '../blocs/friend_event.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequest request;

  const FriendRequestItem({
    super.key,
    required this.request,
  });

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: request.senderAvatar != null
                      ? NetworkImage(request.senderAvatar!)
                      : null,
                  child: request.senderAvatar == null
                      ? Text(
                          request.senderName.isNotEmpty
                              ? request.senderName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getTimeAgo(request.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.message!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (request.status == FriendRequestStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<FriendBloc>().add(
                          AcceptFriendRequest(request.id, request.senderId),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<FriendBloc>().add(
                          RejectFriendRequest(request.id),
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(request.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.rejected:
        return Colors.red;
      case FriendRequestStatus.pending:
        return Colors.lightBlueAccent;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.accepted:
        return 'ACCEPTED';
      case FriendRequestStatus.rejected:
        return 'DECLINED';
      default:

        return 'PENDING';
    }
  }
}
