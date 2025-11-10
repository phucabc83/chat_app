import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/router_app_name.dart';


class UserCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int id;
  const UserCard({required  this.name, required  this.imageUrl,super.key, required this.id});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  int indexSelected = 0;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
      return GestureDetector(
        onTap: (){
          context.pushNamed(AppRouteInfor.chatName,
              queryParameters: {
                'name': widget.name,
                'isGroup': 'false',
                'id':'0',
                'avatar': widget.imageUrl,
                'member': '2',
                'replyTo':widget.id.toString()
              },
              pathParameters: {'id': 0.toString()}

          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.imageUrl),

                ),
                const SizedBox(height: 8),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orangeAccent, width: 5),
                    ),
                ))
              ],
            ),
            Text(widget.name, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
  }
}
