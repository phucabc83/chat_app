

import 'package:flutter/material.dart';

class AvatarTile extends StatelessWidget {
  const AvatarTile({
    super.key,
    required this.url,
    required this.selected,
    required this.onTap,
    this.name
  });
  final String url;
  final bool selected;
  final VoidCallback onTap;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(url),
                child: selected
                    ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellowAccent, width: 3),
                  ),
                )
                    : null,
              ),

              if (name != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    name!,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
