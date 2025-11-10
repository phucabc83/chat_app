import 'package:flutter/material.dart';

import '../../../../core/theme/theme_app.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller ;
  final Widget? prefixIcon ;
  final Widget? suffixIcon ;
  final String hint;
  final int maxLines ;
  const MessageInput({super.key,required this.controller, required this.hint, this.prefixIcon,  this.suffixIcon, this.maxLines=1 });


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

      return Container(
        decoration: BoxDecoration(
          color: DefaultColors.sentMessageInput.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            prefixIcon?? SizedBox(width: 10,),
            SizedBox(width: 5,),
            Expanded(
              child: TextField(
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                controller: controller,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),

                ),
                maxLines: maxLines,
               onSubmitted: (text){
                  print('send mess');
                  controller.clear();
               },
              ),
            ),
            suffixIcon?? Container(),

          ],
        ),
      );
  }

}
