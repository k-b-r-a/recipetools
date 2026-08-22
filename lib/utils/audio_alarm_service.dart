import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioAlarmService {
  static final AudioAlarmService _instance = AudioAlarmService._internal();
  factory AudioAlarmService() => _instance;
  AudioAlarmService._internal();

  static const MethodChannel _platform = MethodChannel('com.example.recipetools/alarm');
  AudioPlayer? _player;
  Timer? _loopTimer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // 1. Try Native Device System Alarm Ringtone via MethodChannel
    try {
      await _platform.invokeMethod('playSystemAlarm');
    } catch (e) {
      debugPrint('Native system alarm error: $e');
      // 2. AudioPlayer Asset Fallback
      try {
        _player ??= AudioPlayer();
        await _player?.stop();
        await _player?.setReleaseMode(ReleaseMode.loop);
        await _player?.play(AssetSource('audio/alarm.wav'));
      } catch (err) {
        debugPrint('AudioPlayer fallback error: $err');
      }
    }

    // 3. Continuous Haptic Vibration & Chime Loop
    _loopTimer?.cancel();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (_isPlaying) {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.vibrate();
      } else {
        _loopTimer?.cancel();
      }
    });
  }

  Future<void> stopAlarm() async {
    _isPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;

    try {
      await _platform.invokeMethod('stopSystemAlarm');
    } catch (e) {
      debugPrint('Native stop system alarm error: $e');
    }

    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('AudioAlarmService stop error: $e');
    }
  }
}
