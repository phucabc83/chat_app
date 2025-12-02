import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({Key? key, required this.post}) : super(key: key);

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.blueAccent.withOpacity(0.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(post.authorId.replaceAll('user_', 'U')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ${post.authorId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(_timeAgo(post.createdAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                  placeholder: (c, s) => Container(height: 180, color: Colors.grey.shade200),
                  errorWidget: (c, s, e) => Container(height: 180, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined)),
                const SizedBox(width: 6),
                IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
                const Spacer(),
                Text('${post.createdAt.toLocal()}'.split(' ')[0], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
