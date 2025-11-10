import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:chat_app/core/service/notification.dart';


class NotifyHelper {
  static final NotifyHelper _instance = NotifyHelper._internal();

  factory NotifyHelper() => _instance;

  NotifyHelper._internal();

  final FlutterLocalNotificationsPlugin _flutter =
  FlutterLocalNotificationsPlugin();
  int _nextId = 1; // id tăng dần

  // Channel info (Android 8+)
  static const _channelId = 'chat_app_default_v2';
  static const _channelName = 'Chat App Channel';
  static const _channelDesc = 'Notifications for chat messages';

  /// Khởi tạo
  Future<void> init() async {
    // Timezone
    tz.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    // iOS settings
    const darwin = DarwinInitializationSettings();

    // Android settings (icon nhỏ trong noti)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
    InitializationSettings(android: android, iOS: darwin);

    await _flutter.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        debugPrint('🔔 Notification tapped: ${resp.payload}');
      },
    );

    // Tạo notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      // Nếu muốn âm custom (đặt file vào res/raw/message.mp3):
      // sound: RawResourceAndroidNotificationSound('message'),
    );

    await _flutter
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Yêu cầu quyền thông báo (Android 13+, iOS)
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  /// Tải avatar từ URL → Bitmap
  Future<AndroidBitmap<Object>> _bitmapFromUrl(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Tải ảnh thất bại: ${resp.statusCode}');
    }
    return ByteArrayAndroidBitmap(Uint8List.fromList(resp.bodyBytes));
  }

  /// NotificationDetails
  Future<NotificationDetails> _details(String? avatar, {
    required String title,
    required String body,
  }) async {
    AndroidBitmap<Object>? bmp;
    if (avatar != null && avatar
        .trim()
        .isNotEmpty) {
      try {
        bmp = await _bitmapFromUrl(avatar);
      } catch (_) {
        bmp = null;
      }
    }

    final style = (bmp != null)
        ? BigPictureStyleInformation(
      bmp,
      contentTitle: title,
      summaryText: body,
      hideExpandedLargeIcon: false,
    )
        : null;

    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      // Nếu muốn âm custom:
      // sound: RawResourceAndroidNotificationSound('message'),
      largeIcon: bmp,
      // styleInformation: style, // hiện ảnh lớn khi kéo xuống
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default', // hoặc 'my_sound.wav' nếu add file vào iOS bundle
    );

    return NotificationDetails(android: android, iOS: ios);
  }

  /// Hiển thị notification
  Future<void> displayNotification({
    required String title,
    required String body,
    required String? avatar,
    String? payload,
  }) async {
    print('🔔 Display notification: $title / $body / $avatar / $payload');
    if (kIsWeb) {
      // Web notification
      await showNotification(
        title: title,
        body: body,
        icon: avatar,
        payload: payload,
      );
      return;
    }
    final id = _nextId++; // tránh ghi đè
    final details = await _details(avatar, title: title, body: body);
    await _flutter.show(id, title, body, details,
        payload: payload ?? '');
  }

  /// Check exact alarm permission (Android 12+)
  Future<bool> checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final st = await Permission.scheduleExactAlarm.status;
        if (!st.isGranted) {
          await Permission.scheduleExactAlarm.request();
          return Permission.scheduleExactAlarm.status.isGranted;
        }
      }
    }
    return true;
  }

}
