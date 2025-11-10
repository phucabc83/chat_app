import 'package:flutter/material.dart';

import '../../../../core/consts/const.dart';


class CustomButton extends StatelessWidget {
  /// A button widget that can be used for signing up.

  final String title;
  final VoidCallback? onPressed;
  const CustomButton({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return  SizedBox(
      width: getWidth(context)*0.7,
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.outline,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child:  Text(title,style: theme.textTheme.bodyMedium,),
      ),
    );
  }
}
