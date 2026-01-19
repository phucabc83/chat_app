import 'package:chat_app/core/utils/util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final appIDString = dotenv.env['AppID'];
    final appSign = dotenv.env['AppSign'];

    final appID = int.tryParse(appIDString ?? '');

    if (appID == null || appSign == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Config lỗi: AppID/AppSign chưa load',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final baseConfig = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();

    if (kIsWeb) {

      baseConfig.pip = ZegoCallPIPConfig(
        enableWhenBackground: false,
      );

    }

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appID,
          appSign: appSign,
          callID: callID,
          userID:Util.userId.toString(),
          userName: Util.userName,
          config: baseConfig,
        ),
      ),
    );
  }
}
