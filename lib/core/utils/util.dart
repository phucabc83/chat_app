import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class Util {



  static String baseUrl = "http://127.0.0.1:6002";

  static String token ='';
  static int userId = 0 ;
  static String userName = '';

  static String avatarUrl = '';

  static String fcmToken = '';
  static bool isEmulator = false;
  static int conversationIdActive = 0;

  static String apiBaseUrl({int port = 6002}) {

    if (kIsWeb) return 'http://localhost:$port';

    if (Platform.isAndroid && isEmulator) return 'http://10.0.2.2:$port'; // Emulator Android
    if (Platform.isIOS) return 'http://localhost:$port';    // iOS Simulator

    // Physical device
    return 'https://hayden-nonpapal-twirly.ngrok-free.dev';
  }


}