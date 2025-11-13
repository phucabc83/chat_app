import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/chat/presentation/blocs/in_coming_call_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/router_app_name.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<InComingCallCubit,InComingCallState>(
      listener: (BuildContext context, InComingCallState state) {
        if(state.status == InComingCallStatus.declined || state.status == InComingCallStatus.missed){
          Navigator.of(context).pop();
        }
        if(state.status ==InComingCallStatus.accepted){
          debugPrint('id ${widget.callID} userIDReceiver ${widget.usernameCaller} userIDCaller ${widget.callerID}');

          context.pushReplacement(
              AppRouteInfor.videoCallPath,
              extra: {
                'callID': widget.callID,
                'userIDReceiver': Util.userId,
                'userIDCaller': widget.callerID,
              },
            );

        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
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
                          onPressed: _rejectCall,
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
                          onPressed:  _acceptCall,
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
      ),
    );
  }

  void _acceptCall() {
    context.read<InComingCallCubit>().acceptCall();
  }

  void _rejectCall() {
    context.read<InComingCallCubit>().declineCall();

  }
}
