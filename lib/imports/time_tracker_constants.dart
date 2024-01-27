// ignore_for_file: constant_identifier_names
const int MILLISECONDS_BEFORE_REPEATING = 10000;

const String LINE_KEY = 'line';
const String STATION_KEY = 'station';
const String ALERT_TIME_KEY = 'alertTime';
const String START_TIME_KEY = 'startTime';
const String TRACKING_TIME_KEY = 'trackingTime';
const String NOTIFIED_TRACKING_TIME_PASSED_KEY = 'notifiedTrackingTimePassed';

const String NOTIFICATION_TITLE = 'Leavo';
const String NOTIFICATION_TEXT = 'Tracking your bus...';
const String TRACKING_TIME_PASSED_TEXT = 'Tracking Time Passed.';
const String LINE_LEFT_TEXT = "The line left the station.";
const String NOTIFICATION_PRESSED_TEXT = "Notification Pressed.";

const String ROUTE_AFTER_NOTIFICATION_PRESS = "/resume-route";

// Android Notification
const String ANDROID_NOTIFICATION_CHANNEL_ID = 'foreground_service';
const String ANDROID_NOTIFICATION_CHANNEL_NAME = 'Foreground Service Notification';
const String ANDROID_NOTIFICATION_CHANNEL_DESCRIPTION = 'Leavo Notification Channel';
const String LAUNCHER = "launcher";