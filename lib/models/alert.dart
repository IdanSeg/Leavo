import 'dart:isolate';
import 'package:audioplayers/audioplayers.dart';
import 'package:leavo/models/journey.dart';
import 'package:leavo/models/time_tracker.dart';

/// Used by the UI to perform UI-specific alert when a non UI trigger is fired.
///
/// This class handles both listening to said triggers, calling the UI and making
/// sure it can be presented to the user. Also handles the audio alert.
class Alert {
  static const String _ALERT_SOUND_PATH = 'sounds/Alert.mp3';
  
  final AudioPlayer _player = AudioPlayer();
  final void Function(int) _whenMatch;
  final void Function() _trackingPassed;
  ReceivePort? _receivePort;

  /// Alert Constructor.
  /// 
  /// [whenMatch] function to call when a match is found.
  /// [trackingPassed] function to call when tracking time passed.
  Alert(
      {required void Function(int) whenMatch,
      required void Function() trackingPassed})
      : _whenMatch = whenMatch,
        _trackingPassed = trackingPassed {
    _receivePort = FlutterForegroundTask.receivePort;
    _receivePort?.listen((data) {
      switch (data.runtimeType) {
        case int:
          _handleInt(data);
          break;
        case String:
          _handleString(data);
          break;
      }
    });
  }

  // Calls functions when a match is found and plays the alert sound.
  void _handleInt(int data) {
    if (data != Journey.NO_REAL_TIME) {
      _showApp();
      _whenMatch(data);
      _playAlert();
    }
  }

  // plays the alert sound continuously.
  Future<void> _playAlert() async {
    _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(_ALERT_SOUND_PATH));
  }

  /// Stops the alert sound and hides the app from the lock screen.
  void stopAlert() {
    _player.stop();
    FlutterForegroundTask.setOnLockScreenVisibility(false);
  }

  // Calls function when tracking time passed and plays the alert sound once.
  void _handleString(String data) {
    if (data == TimeTracker.TRACKING_TIME_PASSED_KEY) {
      _player.play(AssetSource(_ALERT_SOUND_PATH));
      _showApp();
      _trackingPassed();
    }
  }

  // Shows the app to Front even if phone was asleep
  static void _showApp() {
    FlutterForegroundTask.setOnLockScreenVisibility(true);
    FlutterForegroundTask.wakeUpScreen();
    FlutterForegroundTask.launchApp();
  }

  /// Gets rid of the open resources but does not stop the alert.
  void dispose() {
    _receivePort?.close();
  }

  /// Stops the alert and disposes of the open resources.
  void stopAndDispose() {
    stopAlert();
    dispose();
  }
}
