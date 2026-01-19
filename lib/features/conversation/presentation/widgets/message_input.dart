import 'package:flutter/material.dart';
import '../../../../core/theme/theme_app.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String hint;
  final int maxLines;

  /// 🔹 NEW
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const MessageInput({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

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
          prefixIcon ?? const SizedBox(width: 10),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white70),
              textInputAction:
              maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              onChanged: onChanged,
              onSubmitted: (text) {
                onSubmitted?.call(text);
              },
            ),
          ),
          suffixIcon ?? const SizedBox(),
        ],
      ),
    );
  }
}
