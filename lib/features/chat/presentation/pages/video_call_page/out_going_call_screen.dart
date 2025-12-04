import 'package:chat_app/core/routes/router_app_name.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/out_going_call_cubit.dart';

class OutGoingCallScreen extends StatefulWidget {
  final String callID;
  final String avatarUrl;
  final String callType; // 'video' or 'voice'
  final int userIdReceiver;
  final String usernameReceiver;
  final int conversationId;

  const OutGoingCallScreen({
    super.key,
    required this.callID,
    required this.avatarUrl,
     this.callType = 'video',
    required this.userIdReceiver,
    required this.usernameReceiver,
    required  this.conversationId,
  });

  @override
  State<OutGoingCallScreen> createState() => _OutGoingCallScreenState();
}

class _OutGoingCallScreenState extends State<OutGoingCallScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OutGoingCallCubit>().makeCall(widget.callID, widget.userIdReceiver,widget.conversationId);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<OutGoingCallCubit,OutGoingCallState>(

      listener: (BuildContext context, state) {
        debugPrint("✅ state outgoing ${state.status}");

        if(state.status == OutGoingCallStatus.cancel){
        Navigator.of(context).pop();
      }
      if(state.status ==OutGoingCallStatus.success){
          context.pushReplacement(
            AppRouteInfor.videoCallPath,
            extra: {
              'callID': widget.callID,
              'userIDReceiver': widget.userIdReceiver,
              'userIDCaller': Util.userId,
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
            children: [
              const SizedBox(height: 20),
              ClipOval(
                child: Image.network(
                  widget.avatarUrl,
                  width: 80, // 2 * radius
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Đang gọi ${widget.usernameReceiver} ...',
                style: theme.textTheme.bodyLarge
              ),
              const SizedBox(height: 20),
              BlocBuilder<OutGoingCallCubit, OutGoingCallState>(
                buildWhen: (previous, current) => previous.reminderTime != current.reminderTime,
                builder: (context, state) {
                  return   AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // 👈 thời gian hiệu ứng
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.6), // trượt lên nhẹ
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation, // kết hợp fade + slide
                        child: child,
                      ),
                    ),
                    child: Text(
                      '${state.reminderTime}s',
                      key: ValueKey<int>(state.reminderTime), // 👈 cực kỳ quan trọng!
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                },
              ),
              Icon(
                widget.callType == 'video' ? Icons.videocam : Icons.call,
                size: 50,
                color: Colors.green,
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                    onPressed: _cancelCall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.red, // Màu nền đỏ
                    ),
                    child: Text('Hủy cuộc gọi',style: theme.textTheme.bodyLarge)
              )
            )
              )
                  ]
          )
        )],
      ),
    );

  }

  void _cancelCall() {
    context.read<OutGoingCallCubit>().cancelCall(widget.callID, widget.userIdReceiver,widget.conversationId);
  }
}
