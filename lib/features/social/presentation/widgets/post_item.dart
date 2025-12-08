import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/features/social/presentation/widgets/bottom_sheet_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../blocs/posts_cubit.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({Key? key, required this.post}) : super(key: key);

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'bây giờ';
    if (diff.inHours < 1) return '${diff.inMinutes} phút';
    if (diff.inDays < 1) return '${diff.inHours} giờ';
    return '${diff.inDays} ngày';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blueAccent.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(post.avatarUrl),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          post.username,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Builder(
                          builder: (context) {
                            final timeText = _timeAgo(post.createdAt);
                            final isNow = timeText.toLowerCase() == 'bây giờ';
                            return Text(
                              timeText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isNow ? Colors.green : Colors.grey, // nổi bật khi bây giờ
                                fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                                fontSize: isNow ? 14 : 12, // tăng size nếu muốn
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.more_horiz_outlined,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (post.imageUrl != null) ...[
              Image(
                image: CachedNetworkImageProvider(post.imageUrl!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: post.isLiked
                      ? () {}
                      : () => context.read<PostsCubit>().likePost(
                    post.id,
                        ),
                  icon: post.isLiked ? Icon(
                    Icons.favorite,
                    color:Colors.redAccent ,
                    size: 25,
                  ):  Icon(
                    Icons.favorite_outline,
                    color:Colors.white54,
                    size: 25,
                  ),
                  label: Text(
                    '${post.likeCount != 0 ? post.likeCount : ''} Thích',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                TextButton.icon(
                  onPressed:  () =>  showCommentBottomSheet(context: context, postId: post.id,likeCount: post.likeCount),
                  icon: Icon(
                    Icons.comment_outlined,
                    color: Colors.white54,
                    size: 25,
                  ),
                  label: Text(
                    'Bình luận',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share_outlined,
                    color: Colors.white54,
                    size: 25,
                  ),
                  label: Text(
                    'Chia sẽ',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
