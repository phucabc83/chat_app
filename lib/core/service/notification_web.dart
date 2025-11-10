// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// in_app_notifier.dart
import 'package:flutter/material.dart';

import '../routes/router_app.dart';

/// Hiển thị thông báo (trang đang mở)
Future<void> showNotification({
  required String title,
  String? body,
  String? payload,
  String? icon,
}) async {
  // 1) Kiểm tra hỗ trợ
  print('supported=${html.Notification.supported}');
  print('permission=${html.Notification.permission}');
  print('location=${html.window.location.href}');
  if (!html.Notification.supported) {
    print('❌ Notification API not supported');
    return;
  }

  // 2) Yêu cầu quyền nếu chưa có
  if (html.Notification.permission != 'granted') {
    final p = await html.Notification.requestPermission();
    if (p != 'granted') {
      print('❌ Permission not granted: $p');
      return;
    }
  }
  MessageNotifier.showMessage(
    context: RouterApp.rootNavigatorKey.currentContext!,
    sender: title,
    message: body ?? '',
    avatarUrl: icon,
  );
}


class MessageNotifier {
  static void showMessage({
    required BuildContext context,
    required String sender,
    required String message,
    String? avatarUrl,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1E1E1E), // nền tối
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            backgroundColor: Colors.grey[800],
            child: avatarUrl == null || avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 12),
          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
