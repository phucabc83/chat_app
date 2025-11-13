
import 'dart:async';

import 'package:chat_app/core/service/audio_manage.dart';
import 'package:chat_app/core/service/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/util.dart';

class OutGoingCallCubit extends Cubit<OutGoingCallState>{
  int count = 30;

  final SocketService _socketService;

  Timer? _timer;

  OutGoingCallCubit(this._socketService):super(const OutGoingCallState.initial()) {
    debugPrint("✅ OutGoingCallCubit constructor initialized");

  }

  void makeCall(String callID, int userIdReceiver)  {
    emit(state.copyWith(status: OutGoingCallStatus.calling, error: null));
    AudioManager().playAsset('outgoing_audio.mp3');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      emit(state.copyWith(reminderTime:count));

      if (count <= 0 && state.status == OutGoingCallStatus.calling) {
        emit(state.copyWith(status: OutGoingCallStatus.cancel));
        _timer?.cancel();
        count = 30;
        AudioManager().playAsset('end_audio.mp3');
        _socketService.cancelCall(callID,Util.userId,userIdReceiver);


      }
    });
    try {
      _socketService.makeCall(callID, userIdReceiver);

      _socketService.listenCallAccepted((data) {
        debugPrint("✅ call accepted");
        callSuccess(data);
        _timer?.cancel();
        count == 30;
      });

      _socketService.listenCallReject((){
        debugPrint("❌ call rejected");
        emit(state.copyWith(status: OutGoingCallStatus.cancel));
      });
    } catch (e) {
      emit(state.copyWith(status: OutGoingCallStatus.failure, error: e.toString()));
      debugPrint('❌ Error making call: $e');
    }
  }

  void callSuccess(Map<String,dynamic> data) {
    AudioManager().stop();
    emit(state.copyWith(status: OutGoingCallStatus.success, error: null));
  }

  void cancelCall(String callID,int toUserID) {

    _timer?.cancel();
    AudioManager().playAsset('end_audio.mp3');

    emit(state.copyWith(status: OutGoingCallStatus.cancel));
    _socketService.cancelCall(callID,Util.userId,toUserID);
  }
  @override
  Future<void> close() async {
    _timer?.cancel();

    super.close();
  }


}


enum OutGoingCallStatus { initial, calling, success, cancel,failure }

class OutGoingCallState {
  final int reminderTime;
  final OutGoingCallStatus status;
  final String? errorMessage;

  const OutGoingCallState({
    required this.status,
    this.errorMessage,
    this.reminderTime = 30,
  });

  const OutGoingCallState.initial()
      : status = OutGoingCallStatus.initial,
        errorMessage = null,
        reminderTime = 30
  ;

  OutGoingCallState copyWith({
    OutGoingCallStatus? status,
    String? error,
    int? reminderTime,
  }) {
    return OutGoingCallState(
      status: status ?? this.status,
      errorMessage: error,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }



}