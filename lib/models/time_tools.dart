import 'package:intl/intl.dart';

class TimeTools {
  static const String HH_MM = 'HH:mm';
  static const String YYYY_MM_SS = 'yyyy-MM-dd';
  static const String HH_MM_SS = 'HH:mm:ss';
  static const int MINUTES_TO_SECONDS = 60;

  /// Turns to dateTime format with the current date
  ///
  /// [hour] is the hour of the time.
  /// [minute] is the minute of the time.
  static DateTime turnToDateTime(int hour, int minute) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Turns to dateTime format with the current date
  ///
  /// [time] is the time in String type and must be in HH:MM format.
  static DateTime hourMinutesStringToDatetime(String time) {
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    return turnToDateTime(hour, minute);
  }

  /// return current DateTime if after otherTime, else return otherTime
  ///
  /// [otherTime] is the time to compare to. Must be in HH:MM format.
  static DateTime getNowIfAfter(String otherTime) {
    DateTime otherTimeDateTime = hourMinutesStringToDatetime(otherTime);
    DateTime now = DateTime.now();
    return now.isAfter(otherTimeDateTime) ? now : otherTimeDateTime;
  }

  /// Returns the given dateTime in String format.
  ///
  /// Only 3 digits of the milliseconds are kept.
  static String dateTimeToString(DateTime dateTime) {
    String? startTimeString = dateTime.toString();
    startTimeString =
        startTimeString.substring(0, startTimeString.lastIndexOf('.') + 4);
    return startTimeString;
  }

  /// Returns the DateTime of the given String.
  /// 
  /// [time] is the time in String type and must be in yyyy-MM-dd HH:mm:ss.SSS format.
  static DateTime fullTimeStringToDateTime(String startTimeString) =>
    DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(startTimeString);

  /// Returns the difference between the given time and now.
  /// 
  /// [time] is the time in DateTime type.
  /// Useful for datetime whose accuracy is unknown.
  static Duration differenceFromUnsafeDatetime(DateTime time) {
    String? startTimeString = TimeTools.dateTimeToString(time);
    DateTime startTime = TimeTools.fullTimeStringToDateTime(startTimeString);
    return DateTime.now().difference(startTime);
  }
}
