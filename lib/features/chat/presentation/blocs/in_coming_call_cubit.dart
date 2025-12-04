import 'package:chat_app/core/service/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service/audio_manage.dart';

class InComingCallCubit extends Cubit<InComingCallState> {

  final SocketService  socketService;
  InComingCallCubit(this.socketService) : super(const InComingCallState.initial());


  void init() {
    socketService.listenCallReceived(_receiveCall);
  }

  void ringingCall({
    required String usernameCaller,
    required String avatarUrlCaller,
    required int callerID,
    required String callID,
    required int reminderTime,
    required int conversationId,
  }) {
    AudioManager().playAsset('incoming_audio.mp3');


    emit(state.copyWith(
        status: InComingCallStatus.ringing,
        usernameCaller: usernameCaller,
        avatarUrlCaller: avatarUrlCaller,
        callerID: callerID,
        callID: callID,
        reminderTime: reminderTime,
        conversationId: conversationId
      )
      );
  }
  void acceptCall() {
    AudioManager().stop();

    if(state.status == InComingCallStatus.ringing){
      emit(state.copyWith(
        status: InComingCallStatus.accepted,
      )
      );
      socketService.acceptCall(state.callID!,state.callerID!,state.conversationId);

    }

  }

  void declineCall() {
   if(state.status == InComingCallStatus.ringing){
     AudioManager().playAsset('end_audio.mp3',isLoop: false);

     emit(state.copyWith(status: InComingCallStatus.declined));
     socketService.rejectCall(state.callID!,state.callerID!,state.conversationId);
   }

  }

  void missedCall() {
    if (state.status == InComingCallStatus.ringing) {
      debugPrint('📞 Missed call from ${state.usernameCaller}');
      AudioManager().playAsset('end_audio.mp3',isLoop: false);

      emit(state.copyWith(
        status: InComingCallStatus.missed,
      )
      );


    }
  }

  _receiveCall(Map<String, dynamic> data) {
    debugPrint('📞 Incoming call data received: $data');
    ringingCall(
      usernameCaller: data['fromUserName'],
      avatarUrlCaller: data['fromAvatarUrl'],
      callerID: data['fromUserID'],
      callID: data['callID'],
      reminderTime: data['reminderTime'],
      conversationId:data['conversationId']
    );

    socketService.listenCancelCall(
      () => missedCall(),
    );
  }



  @override
  Future<void> close() async {
    AudioManager().stop();
    super.close();
  }

}


enum InComingCallStatus {
  idle,
  ringing,
  accepted,
  declined,
  missed,
}
class InComingCallState {
  final InComingCallStatus status;
  final String? error;
  final int reminderTime;

  // required String usernameCaller,
  // required String avatarUrlCaller,
  // required int callerID,
  // required int callID,
  // required int reminderTime
  final String? usernameCaller;
  final String? avatarUrlCaller;
  final int? callerID;
  final String? callID;
  final int conversationId;
  InComingCallState({
    required this.status,
    required this.error,
    required this.reminderTime,
    this.usernameCaller,
    this.avatarUrlCaller,
    this.callerID,
    this.callID,
    required this.conversationId,
  });

  const InComingCallState.initial():
        status = InComingCallStatus.idle,
        error = null,
        reminderTime = 30,
        usernameCaller = null,
        avatarUrlCaller = null,
        callerID = null,
        callID = null,
        conversationId = 0;


        InComingCallState copyWith({
          InComingCallStatus? status,
          String? error,
          int? reminderTime,
           String? usernameCaller,
           String? avatarUrlCaller,
           int? callerID,
           String? callID,
            int? conversationId,
        }) {
          return InComingCallState(
              status: status ?? this.status,
              error: error ?? this.error,
              reminderTime: reminderTime ?? this.reminderTime,
              usernameCaller: usernameCaller ?? this.usernameCaller,
              avatarUrlCaller: avatarUrlCaller ?? this.avatarUrlCaller,
              callerID: callerID ?? this.callerID,
              callID: callID ?? this.callID,
              conversationId: this.conversationId,
          );
        }

}