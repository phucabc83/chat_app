import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';

class UserSearchItem extends StatelessWidget {
  final Friend user;
  final Function(int userId, String? message) onSendRequest;

  const UserSearchItem({
    super.key,
    required this.user,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.avatar != null
              ? NetworkImage(user.avatar!)
              : null,
          child: user.avatar == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _showSendRequestDialog(context),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  void _showSendRequestDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Friend Request to ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a personal message (optional):',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Hi! I would like to add you as a friend.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),

          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSendRequest(
                user.id,
                messageController.text.trim().isNotEmpty
                    ? messageController.text.trim()
                    : null,
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
