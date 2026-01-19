import 'package:flutter/material.dart';

class BuildPromt extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subTitle;
  const BuildPromt({super.key, this.onTap, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return  GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: subTitle,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          children: <TextSpan>[
            TextSpan(
              text: title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),

            ),
          ],
        ),
      ),
    );

  }
}
