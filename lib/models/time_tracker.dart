import 'package:leavo/imports/time_tracker_imports.dart';
export 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Creation of the foreground task that tracks the alert time of the journey.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TimeTracker());
}

/// The foreground task that tracks the alert time of the journey.
///
/// The task is started by [startForegroundTask]
/// Must be called only after [requestPermissionForAndroid] has been called.
class TimeTracker extends TaskHandler {
  SendPort? _sendPort;
  Journey? _journey;
  int? _match;
  bool _journeyBegun = false;
  static const String TRACKING_TIME_PASSED_KEY = TRACKING_TIME_PASSED_TEXT;
  static const String LINE_LEFT_KEY = LINE_LEFT_TEXT;

  /// Starts the foreground task.
  ///
  /// [journey] is the journey that the user wants to track.
  /// [trackingTime] timoeout to notify the user that the tracking time has
  /// passed.
  // could not be a normal constructor as it is async
  static void startForegroundTask(Journey journey, int trackingTime) async {
    _initForegroundTask();
    await _initializeData(journey, trackingTime);
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.restartService();
    } else {
      FlutterForegroundTask.startService(
        notificationTitle: NOTIFICATION_TITLE,
        notificationText: NOTIFICATION_TEXT,
        callback: startCallback,
      );
    }
  }

  // Saves the data to be later retrieved by the foreground task.
  static Future<void> _initializeData(Journey journey, int trackingTime) async {
    // only basic types can be saved so Journey is saved as its parameters
    await FlutterForegroundTask.saveData(key: LINE_KEY, value: journey.line);
    await FlutterForegroundTask.saveData(
        key: STATION_KEY, value: journey.station);
    await FlutterForegroundTask.saveData(
        key: ALERT_TIME_KEY, value: journey.alertTime);
    // only basic types can be saved so startTime is saved as a String
    String? startTimeString = TimeTools.dateTimeToString(journey.startTime);
    await FlutterForegroundTask.saveData(
        key: START_TIME_KEY, value: startTimeString);
    await FlutterForegroundTask.saveData(
        key: TRACKING_TIME_KEY, value: trackingTime);
    await FlutterForegroundTask.saveData(
        key: TRACKING_TIME_PASSED_KEY, value: false);
  }

  /// Called when the task is started.
  ///
  /// [timestamp] is the time the task was started.
  /// [sendPort] is the port to send messages to the task.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    String? line = await FlutterForegroundTask.getData<String>(key: LINE_KEY);
    String? station =
        await FlutterForegroundTask.getData<String>(key: STATION_KEY);
    int? alertTime =
        await FlutterForegroundTask.getData<int>(key: ALERT_TIME_KEY);
    String? startTimeString =
        await FlutterForegroundTask.getData<String>(key: START_TIME_KEY);

    if (startTimeString != null &&
        line != null &&
        station != null &&
        alertTime != null) {
      DateTime startTime = TimeTools.fullTimeStringToDateTime(startTimeString);
      _journey = Journey(
          line: line,
          station: station,
          alertTime: alertTime,
          startTime: startTime);
    }
  }

  /// Called every [interval] milliseconds in [ForegroundTaskOptions].
  ///
  /// [timestamp] is the time the task was started.
  /// [sendPort] is the port to send messages to the task.
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    if (_journey == null) {
      return;
    } else if (!_journeyBegun) {
      _match = await _journey?.matchingRealTimeExists();
      if (_match != Journey.NO_REAL_TIME) {
        sendPort?.send(_match);
        _journeyBegun = true;
      }
      await _checkTrackingTime(sendPort, _match);
    } else {
      int? minutesLeft = await _journey?.getMinutesLeft();
      if (minutesLeft == Journey.NO_REAL_TIME) {
        sendPort?.send(LINE_LEFT_TEXT);
        FlutterForegroundTask.stopService();
      } else {
        sendPort?.send(
          minutesLeft,
        );
      }
    }
  }

  // Check if passed tracking time and notify if so
  Future<void> _checkTrackingTime(SendPort? sendPort, int? match) async {
    bool? notifiedTrackingTimePassed =
        await FlutterForegroundTask.getData<bool>(
            key: TRACKING_TIME_PASSED_KEY);
    if (match == Journey.NO_REAL_TIME &&
        !notifiedTrackingTimePassed!) {
      Duration diff =
          TimeTools.differenceFromUnsafeDatetime(_journey!.startTime);
      int? trackingTime =
          await FlutterForegroundTask.getData<int>(key: TRACKING_TIME_KEY);
      if (diff.inSeconds >= trackingTime! * TimeTools.MINUTES_TO_SECONDS) {
        sendPort?.send(TRACKING_TIME_PASSED_KEY);
        await FlutterForegroundTask.saveData(
            key: TRACKING_TIME_PASSED_KEY, value: true);
      }
    }
  }

  /// Called when the task is destroyed. Required by interface.
  ///
  /// [timestamp] is the time the task was started.
  /// [sendPort] is the port to send messages to the task.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  // notification and foreground task initializations
  static void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: ANDROID_NOTIFICATION_CHANNEL_ID,
      channelName: ANDROID_NOTIFICATION_CHANNEL_NAME,
      channelDescription:
          ANDROID_NOTIFICATION_CHANNEL_DESCRIPTION,
      channelImportance: NotificationChannelImportance.MIN,
      priority: NotificationPriority.MIN,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: LAUNCHER,
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: MILLISECONDS_BEFORE_REPEATING,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}


  /// Called when the notification itself on the Android platform is pressed.
  ///
  /// "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  /// this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp(ROUTE_AFTER_NOTIFICATION_PRESS);
    _sendPort?.send(NOTIFICATION_PRESSED_TEXT);
  }
}

/// Requests the permissions required for the foreground task to run.
Future<void> requestPermissionForAndroid() async {
  if (!Platform.isAndroid) {
    return;
  }
  if (!await FlutterForegroundTask.canDrawOverlays) {
    // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
    await FlutterForegroundTask.openSystemAlertWindowSettings();
  }
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
}
