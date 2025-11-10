import 'dart:io';

import 'package:flutter/foundation.dart';

class Util {



  static String baseUrl = "http://127.0.0.1:6002";
  static String token ='';
  static int userId = 0 ;
  static String userName = '';

  static String avatarUrl = '';

  static String fcmToken = '';

  static String apiBaseUrl() {
    const port = 6002;
    if (kIsWeb) return 'http://localhost:$port';
    // if (Platform.isAndroid) return 'http://10.0.2.2:$port'; // AVD
    if (Platform.isIOS) return 'http://localhost:$port';     // Simulator
    return 'http://192.168.1.7:$port';
  }

}