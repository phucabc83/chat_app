import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:chat_app/core/utils/util.dart';

class VideoCallPage extends StatefulWidget {
  final String callID;
  final int userIDCaller;
  final int userIDReceiver;

  const VideoCallPage({
    super.key,
    required this.callID,
    required this.userIDCaller,
    required this.userIDReceiver,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _permissionGranted = false;
  bool _requesting = true;
  bool _validatingCredentials = false;
  bool _credentialsValid = false;
  String? _errorMessage;

  late final int appID;
  late final String appSign;

  @override
  void initState() {
    super.initState();

    // Lấy credentials từ .env
    try {
      appID = int.parse(dotenv.env['AppID']!);
      appSign = dotenv.env['AppSign']!;

      debugPrint('🔑 Loaded credentials:');
      debugPrint('AppID: $appID');
      debugPrint('AppSign: $appSign');
    } catch (e) {
      debugPrint('❌ Failed to load credentials: $e');
      _errorMessage = 'Không thể load AppID/AppSign từ .env file';
      setState(() => _requesting = false);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoCall();
    });
  }

  /// Khởi tạo video call với validation
  Future<void> _initializeVideoCall() async {
    // Bước 1: Validate credentials
    setState(() {
      _validatingCredentials = true;
      _errorMessage = null;
    });

    // final isValid = await _validateZegoCredentials();

    if (!mounted) return;

    // if (!isValid) {
    //   setState(() {
    //     _validatingCredentials = false;
    //     _requesting = false;
    //   });
    //   return;
    // }

    // Bước 2: Request permissions
    setState(() {
      _credentialsValid = true;
      _validatingCredentials = false;
    });

    await _requestAllPermissionsOnce();
  }

  /// Validate Zego credentials
  // Future<bool> _validateZegoCredentials() async {
  //   try {
  //     debugPrint('🔍 Validating Zego credentials...');
  //
  //     // Kiểm tra format cơ bản
  //     if (appID <= 0) {
  //       _errorMessage = '❌ AppID không hợp lệ (phải > 0)';
  //       debugPrint(_errorMessage);
  //       return false;
  //     }
  //
  //     if (appSign.isEmpty || appSign.length != 32) {
  //       _errorMessage = '❌ AppSign phải có đúng 32 ký tự hex';
  //       debugPrint(_errorMessage);
  //       return false;
  //     }
  //
  //     // Kiểm tra AppSign chỉ chứa hex
  //     final hexPattern = RegExp(r'^[a-f0-9]+$', caseSensitive: false);
  //     if (!hexPattern.hasMatch(appSign)) {
  //       _errorMessage = '❌ AppSign chỉ được chứa ký tự hex (0-9, a-f)';
  //       debugPrint(_errorMessage);
  //       return false;
  //     }
  //
  //     // Test tạo engine để verify credentials - ONLY on mobile
  //     if (!kIsWeb) {
  //       try {
  //         // Destroy engine cũ nếu có (bỏ qua lỗi)
  //         try {
  //           await ZegoExpressEngine.destroyEngine();
  //           await Future.delayed(const Duration(milliseconds: 200));
  //           debugPrint('🧹 Old engine destroyed');
  //         } catch (e) {
  //           debugPrint('⚠️ No old engine to destroy (expected): $e');
  //         }
  //
  //         // Tạo engine mới - createEngineWithProfile trả về void
  //         try {
  //           debugPrint('🔧 Creating engine with AppID: $appID, AppSign: ${appSign.substring(0, 8)}...');
  //
  //           // Không cần gán vào biến vì method này trả về void
  //           await ZegoExpressEngine.createEngineWithProfile(
  //             ZegoEngineProfile(
  //               appID,
  //               ZegoScenario.Default,
  //               appSign: appSign,
  //             ),
  //           ).timeout(
  //             const Duration(seconds: 10),
  //             onTimeout: () {
  //               throw TimeoutException('Engine creation timeout after 10s');
  //             },
  //           );
  //
  //           debugPrint('✅ Engine created successfully!');
  //         } catch (createError) {
  //           debugPrint('❌ Create engine error: $createError');
  //
  //           final errorStr = createError.toString().toLowerCase();
  //
  //           if (errorStr.contains('null object reference') || errorStr.contains('nullpointer')) {
  //             _errorMessage = '❌ Lỗi khởi tạo engine (null pointer).\n'
  //                 'Nguyên nhân:\n'
  //                 '1. AppSign không đúng\n'
  //                 '2. Thiếu ProGuard rules\n'
  //                 '3. Chạy: flutter clean && flutter run';
  //           } else if (errorStr.contains('1001001') || errorStr.contains('invalid')) {
  //             _errorMessage = '❌ AppID hoặc AppSign KHÔNG HỢP LỆ!\n'
  //                 'Vui lòng kiểm tra lại trên Zego Console.';
  //           } else if (errorStr.contains('timeout')) {
  //             _errorMessage = '❌ Timeout - kiểm tra kết nối mạng';
  //           } else {
  //             _errorMessage = '❌ Lỗi: ${createError.toString()}';
  //           }
  //           return false;
  //         }
  //
  //         // Test version nếu engine OK
  //         try {
  //           final version = await ZegoExpressEngine.getVersion();
  //           debugPrint('✅ Zego SDK Version: $version');
  //         } catch (e) {
  //           debugPrint('⚠️ Version check failed (non-critical): $e');
  //         }
  //
  //         // Destroy engine sau khi validate
  //         try {
  //           await ZegoExpressEngine.destroyEngine();
  //           await Future.delayed(const Duration(milliseconds: 200));
  //           debugPrint('✅ Validation complete - Engine destroyed');
  //         } catch (e) {
  //           debugPrint('⚠️ Destroy engine failed (non-critical): $e');
  //         }
  //
  //         return true;
  //       } on PlatformException catch (e) {
  //         debugPrint('❌ PlatformException: ${e.code} - ${e.message}');
  //         _errorMessage = '❌ Lỗi platform: ${e.message}';
  //         return false;
  //       } on TimeoutException catch (e) {
  //         debugPrint('❌ TimeoutException: $e');
  //         _errorMessage = '❌ Timeout: Kiểm tra kết nối mạng';
  //         return false;
  //       } catch (e) {
  //         debugPrint('❌ Unexpected error: $e');
  //         _errorMessage = '❌ Lỗi không xác định: $e';
  //         return false;
  //       }
  //     }
  //
  //     // Web không cần validate engine
  //     debugPrint('✅ Web platform - Skip engine validation');
  //     return true;
  //   } catch (e) {
  //     debugPrint('❌ Validation error: $e');
  //     _errorMessage = '❌ Lỗi validate: $e';
  //     return false;
  //   }
  // }

  /// Request permissions
  Future<void> _requestAllPermissionsOnce() async {
    if (kIsWeb) {
      setState(() {
        _permissionGranted = true;
        _requesting = false;
      });
      return;
    }

    debugPrint('📱 Requesting permissions...');

    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.bluetoothConnect,
      ].request();

      final granted = statuses.values.every((e) => e.isGranted);

      debugPrint('Permissions status:');
      statuses.forEach((permission, status) {
        debugPrint('  ${permission.toString()}: ${status.toString()}');
      });

      setState(() {
        _permissionGranted = granted;
        _requesting = false;
      });

      if (!granted) {
        _errorMessage = '❌ Cần cấp quyền Camera & Microphone để thực hiện cuộc gọi';
      }
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      setState(() {
        _permissionGranted = false;
        _requesting = false;
        _errorMessage = '❌ Lỗi khi xin quyền: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state - đang validate credentials
    if (_validatingCredentials) {
      return _buildLoadingUI('Đang kiểm tra credentials...');
    }

    // Loading state - đang request permissions
    if (_requesting) {
      return _buildLoadingUI('Đang xin quyền truy cập...');
    }

    // Error state - credentials không hợp lệ
    if (!_credentialsValid) {
      return _buildErrorUI(
        icon: Icons.error_outline,
        title: 'Credentials không hợp lệ',
        message: _errorMessage ?? 'Không thể validate AppID/AppSign',
        actionText: 'Kiểm tra lại',
        onAction: () {
          setState(() {
            _validatingCredentials = true;
            _errorMessage = null;
          });
          // _validateZegoCredentials().then((isValid) {
          //   if (mounted) {
          //     setState(() {
          //       _credentialsValid = isValid;
          //       _validatingCredentials = false;
          //     });
          //     if (isValid) {
          //       _requestAllPermissionsOnce();
          //     }
          //   }
          // });
        },
      );
    }

    // Error state - permissions bị từ chối
    if (!_permissionGranted) {
      return _buildErrorUI(
        icon: Icons.videocam_off,
        title: 'Cần quyền truy cập',
        message: _errorMessage ?? 'Cần quyền Camera & Microphone để thực hiện cuộc gọi video',
        actionText: 'Cấp quyền',
        onAction: () {
          setState(() => _requesting = true);
          _requestAllPermissionsOnce();
        },
        secondaryActionText: 'Mở cài đặt',
        onSecondaryAction: () => openAppSettings(),
      );
    }

    // Success state - hiển thị video call
    return _buildVideoCall();
  }

  Widget _buildLoadingUI(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              if (secondaryActionText != null && onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onSecondaryAction,
                  icon: const Icon(Icons.settings),
                  label: Text(secondaryActionText),
                ),
              ],
              const SizedBox(height: 32),
              // Debug info
              if (!kIsWeb)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Info:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('AppID: $appID', style: const TextStyle(fontSize: 12)),
                      Text(
                        'AppSign: ${appSign.substring(0, 8)}...',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCall() {
    final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
      ..turnOnCameraWhenJoining = true
      ..turnOnMicrophoneWhenJoining = true
      ..useSpeakerWhenJoining = true
      ..useFrontCameraWhenJoining = true
      ..enableAccidentalTouchPrevention = false; // Tắt proximity sensor để tránh loading liên tục


    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appID,
          appSign: appSign,
          callID: widget.callID,
          userID: Util.userId.toString(),
          userName: Util.userName,
          config: config,
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🔚 VideoCallPage disposed');
    super.dispose();
  }
}

// ========================================
// HELPER CLASS: ZegoCallService
// Dùng để khởi tạo và validate Zego trong main.dart
// ========================================

class ZegoCallService {
  static int? _appID;
  static String? _appSign;
  static bool _isInitialized = false;

  /// Khởi tạo Zego credentials trong main()
  static Future<bool> initialize() async {
    try {
      _appID = int.parse(dotenv.env['AppID']!);
      _appSign = dotenv.env['AppSign']!;

      debugPrint('🔑 ZegoCallService initialized');
      debugPrint('AppID: $_appID');
      debugPrint('AppSign: $_appSign');

      // Validate ngay
      final isValid = await _validateCredentials();
      _isInitialized = isValid;

      return isValid;
    } catch (e) {
      debugPrint('❌ ZegoCallService initialization failed: $e');
      return false;
    }
  }

  static Future<bool> _validateCredentials() async {
    if (_appID == null || _appSign == null) return false;

    try {
      if (kIsWeb) return true;

      await ZegoExpressEngine.destroyEngine().catchError((_) {});

      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          _appID!,
          ZegoScenario.Default,
          appSign: _appSign!,
        ),
      );

      debugPrint('✅ Credentials validated successfully');

      await ZegoExpressEngine.destroyEngine();
      return true;
    } catch (e) {
      debugPrint('❌ Credentials validation failed: $e');
      return false;
    }
  }

  static bool get isInitialized => _isInitialized;
  static int? get appID => _appID;
  static String? get appSign => _appSign;
}