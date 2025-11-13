import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();



  Future<void> playAsset(String audioName, {bool isLoop = true}) async {

    if(_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
      await _audioPlayer.stop();
    }
    await _audioPlayer.setReleaseMode(
        isLoop ? ReleaseMode.loop : ReleaseMode.release);

    debugPrint('Playing asset audio: $audioName');
    await _audioPlayer.play(AssetSource('sounds/$audioName'));
  }

  Future<void> playUrl(String url) async {
    if(_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();

      await _audioPlayer.stop();
    }
    await _audioPlayer.play(UrlSource(url));
  }

  // Dừng audio
  Future<void> stop() async {
    if(_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();

      await _audioPlayer.stop();
    }
  }

  // Tạm dừng
  Future<void> pause() async {
    if(_audioPlayer.state == PlayerState.playing){
      await _audioPlayer.pause();
    }
  }

  // Tiếp tục
  Future<void> resume() async {
    if(_audioPlayer.state == PlayerState.paused){
      await _audioPlayer.resume();
    }
  }
  Future<void> dispose() async {
    await _audioPlayer.pause();

    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }
}
