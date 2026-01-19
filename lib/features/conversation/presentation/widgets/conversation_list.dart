import 'package:chat_app/features/conversation/domain/entities/conversation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/routes/router_app_name.dart';


class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;

  const ConversationList({super.key, required this.conversations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) => Divider(color: theme.colorScheme.outline),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return MessageCard(conversation: conversation);
      },
    );
  }
}

class MessageCard extends StatefulWidget {
  final Conversation conversation;

  const MessageCard({super.key, required this.conversation});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String title = widget.conversation.isGroup
        ? (widget.conversation.nameGroup ?? '[No Name]')
        : widget.conversation.friendUserName;

    final String avatarUrl =
        widget.conversation.avatarUrl ??
        'https://i.pravatar.cc/300?img=${widget.conversation.conversationId % 70 + 1}';


    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRouteInfor.chatName,
          pathParameters: {'id': widget.conversation.conversationId.toString()},
          queryParameters: {
            'name': title,
            'isGroup': widget.conversation.isGroup.toString(),
            'avatar': avatarUrl,
            'member': widget.conversation.member.toString(),
          },
        );

        setState(() {
          debugPrint('setstate conversation ');

          widget.conversation.unreadCount = 0;
        });

      },
      child: ListTile(
        leading: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: avatarUrl,
          imageBuilder: (context, imageProvider) =>
              CircleAvatar(radius: 30, backgroundImage: imageProvider),
          placeholder: (context, url) => const CircleAvatar(
            radius: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) {
            return CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.error, color: Colors.red),
            );
          },
        ),
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          contentMessage(widget.conversation.lastMessage ?? ''),
          style: theme.textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.conversation.unreadCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(width: 16.0),
            if (widget.conversation.lastMessageTime != null)
              Text(
                DateFormat('HH:mm').format(widget.conversation.lastMessageTime!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String contentMessage(String content) {
    final parts = splitContent(content);

    for (final part in parts) {
      if (isImageUrl(part)) return '🖼️ Ảnh';
      if (isLocation(part)) return '📍 Vị trí';
    }

    return parts.isNotEmpty ? parts.last : '';
  }
  List<String> splitContent(String content) {
    return content.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  bool isImageUrl(String text) {
    return text.startsWith('http') &&
        (text.endsWith('.jpg') ||
            text.endsWith('.png') ||
            text.endsWith('.jpeg') ||
            text.endsWith('.webp'));
  }

  bool isLocation(String text) {
    return RegExp(r'^-?\d+(\.\d+)?,-?\d+(\.\d+)?\|').hasMatch(text);
  }

  bool isUrl(String s) {
    final uri = Uri.tryParse(s);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
  }
}
