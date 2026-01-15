// lib/core/service/fcm_service.dart
import 'package:chat_app/core/service/notify_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/friend/friend_injection.dart';
import 'api_service.dart';
import '../utils/util.dart';

class FcmService {
  /// Gọi 1 lần sau khi user đăng nhập (có userId)
  Future<void> setupPush() async {
    if (Util.userId == 0) return;

    print('🚀 Setting up FCM...');
    final messaging = FirebaseMessaging.instance;

    // 1) Quyền thông báo
    var settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined || settings.authorizationStatus == AuthorizationStatus.denied) {
      settings = await messaging.requestPermission();
    }

    print('🔔 Permission: ${settings.authorizationStatus}');

    // 2) Lấy token (web cần VAPID)
    String? token;
    if (kIsWeb) {
      final key = dotenv.env['VAPID_KEY'] ?? '';
      final vapidKey = key;
      token = await messaging.getToken(vapidKey: vapidKey);
    } else {
      token = await messaging.getToken();
    }

    if (token == null || token.isEmpty) {
      print('❌ FCM token null/empty (kiểm tra HTTPS, service worker cho web, VAPID key).');
      return;
    }

    // 3) Gửi token lên server & lưu tạm
    await sl<ApiService>().tokenFcm(token);
    Util.fcmToken = token;
    print('${kIsWeb ? "🌐" : "📱"} FCM Token: $token');

    // 4) Lắng token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await sl<ApiService>().tokenFcm(newToken);
      Util.fcmToken = newToken;
      print('🔄 FCM token refreshed: $newToken');
    });

    // 5) Foreground message (tab/app đang mở)
    FirebaseMessaging.onMessage.listen((RemoteMessage m) {

      print('🖱️ Fc Title data: ${m.notification?.title ?? 'No title'}');

      print('Data: ${m.data}');

      NotifyHelper().displayNotification(
        title: m.notification?.title ?? 'No title',
        body: m.notification?.body ?? 'No body',
        payload: m.data['conversationId']?.toString() ?? '',
        avatar: m.data['avatar']?.toString() ?? '',
      );

    });

    // 6) User click notification để mở app/tab
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      print('🖱️ onMessageOpenedApp data: ${m.data}');
      final convId = m.data['conversationId'];
      // TODO: điều hướng đến màn hình hội thoại convId
    });
  }
}
