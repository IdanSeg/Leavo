import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:leavo/imports/database_keys.dart';

/// A class that represents a single journey in public transport.
///
/// Capable of getting the real time of the next arrivals of the line in the
/// station, and determining if the time is right for the user's alert.
class Journey {
  final String _line;
  final String _station;
  final int _alertTime;
  final DateTime _startTime;
  dynamic _stationData;
  int? _lastRealTime;

  /// The token returned when no real time is available, or line passed.
  static const NO_REAL_TIME = -1;

  /// The separator between the line\station number and the line\station name.
  static const NUMBER_AND_NAME_SEPARATOR = ' | ';

  /// The position of the line\station number in the line\station string.
  static const NUMBER_POSITION = 0;

  /// The position of the line\station name in the line\station string.
  static const NAME_POSITION = 1;

  // The allowed time difference between the last real time of tracked
  //line and new one. Checked by first, second, third.
  static const int FIRST_ALLOWED_TIME_DIFFERENCE = 0;
  static const int SECOND_ALLOWED_TIME_DIFFERENCE = 1;
  static const int THIRD_ALLOWED_TIME_DIFFERENCE = 2;

  /// Journey Constructor.
  ///
  /// [line] line of the journey in the format NAME | NUMBER.
  /// [station] station number of the journey in the format NAME | NUMBER.
  /// [alertTime] desired time for the alert in minutes.
  /// [startTime] time the user wishes to start getting alerts.
  Journey(
      {required String line,
      required String station,
      required int alertTime,
      required DateTime startTime})
      : _line = line,
        _station = station,
        _alertTime = alertTime,
        _startTime = startTime;

  // Accepts description of the format NAME | NUMBER and returns the number.
  static String _getNumber(String description) {
    return description.split(NUMBER_AND_NAME_SEPARATOR)[NUMBER_POSITION];
  }

  /// Getters.
  get line => _line;
  get station => _station;
  get alertTime => _alertTime;
  get startTime => _startTime;

  // Returns the data of the station from the web api.
  Future<dynamic> _getStationData() async {
    final url = WEB_API_PREFIX + _getNumber(_station) + WEB_API_SUFFIX;
    final response = await http.get(Uri.parse(url));
    _stationData = jsonDecode(response.body);
  }

  /// Returns a list of the real times of the next arrivals to the station.
  Future<List<dynamic>> getRealTime() async {
    await _getStationData();
    for (final curLineData in _stationData) {
      if (curLineData[LINE_NUMBER_PROPERTY] == _getNumber(_line)) {
        return curLineData[REAL_TIME_LIST_PROPERTY];
      }
    }
    return [NO_REAL_TIME];
  }

  /// Sets the last real time of the journey.
  void lastRealTime(int lastRealTime) => _lastRealTime = lastRealTime;

  // Returns the real time if properties are matched.
  int _timeIsRight(List<String> realTimeList) {
    for (int i = 0; i < realTimeList.length; i++) {
      int realTime = int.parse(realTimeList[i]);
      if (realTime == _alertTime && DateTime.now().isAfter(_startTime)) {
        _lastRealTime = realTime;
        return realTime;
      }
    }
    return NO_REAL_TIME;
  }

  /// Returns real time if journey's properties are matched,
  /// or NO_REAL_TIME otherwise.
  Future<int> matchingRealTimeExists() async {
    List<dynamic> realTimeListDynamic = await getRealTime();
    return _timeIsRight(
        realTimeListDynamic.map((item) => item.toString()).toList());
  }

  // Returns real time if one exists in the [RealTimeList]
  //which up to [allowedTimeDifference]
  int _closeRealTimeExists(List<int> realTimeList, int allowedTimeDifference) {
    for (int i = 0; i < realTimeList.length; i++) {
      int realTime = realTimeList[i];
      if ((realTime - _lastRealTime!).abs() <= allowedTimeDifference) {
        _lastRealTime = realTime;
        return realTime;
      }
    }
    return NO_REAL_TIME;
  }

  /// Returns real time of line closest to the last real time.
  ///
  /// If no real time exists, returns NO_REAL_TIME.
  /// Must be called after [matchingRealTimeExists] or lastRealTime is set.
  Future<int> getMinutesLeft() async {
    List<dynamic> realTimeListDynamic = await getRealTime();
    List<int> realTimeList = realTimeListDynamic
        .map<int>((item) => int.parse(item.toString()))
        .toList();
    int sameRealTime =
        _closeRealTimeExists(realTimeList, FIRST_ALLOWED_TIME_DIFFERENCE);
    if (sameRealTime != NO_REAL_TIME) {
      return sameRealTime;
    }
    int closeRealTime =
        _closeRealTimeExists(realTimeList, SECOND_ALLOWED_TIME_DIFFERENCE);
    if (closeRealTime != NO_REAL_TIME) {
      return closeRealTime;
    }
    return _closeRealTimeExists(realTimeList, THIRD_ALLOWED_TIME_DIFFERENCE);
  }
}
