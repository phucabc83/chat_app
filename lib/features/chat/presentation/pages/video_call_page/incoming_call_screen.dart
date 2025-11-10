import 'package:flutter/material.dart';

class IncomingCallScreen extends StatefulWidget {
  final String usernameCaller;
  final String avatarUrlCaller;
  final int callerID;
  final String callID;
  final String callType;
  final int reminderTime;
  const IncomingCallScreen({
    super.key,
    required this.usernameCaller,
    required this.avatarUrlCaller,
    required this.callerID,
    required this.callID,
    this.callType = 'video',
    required this.reminderTime,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/call_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20),
              ClipOval(
                child: Image.network(
                  widget.avatarUrlCaller,
                  width: 80, // 2 * radius
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ' Cuộc gọi từ ${widget.usernameCaller} ',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Icon(
                widget.callType == 'video' ? Icons.videocam : Icons.call,
                size: 50,
                color: Colors.green,
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.red, // Màu nền đỏ
                        ),
                        // icon reject call
                        child: Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.orangeAccent, // Màu nền đỏ
                        ),
                        child: Icon(Icons.call, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
