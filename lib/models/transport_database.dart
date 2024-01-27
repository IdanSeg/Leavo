import 'dart:convert';
import 'package:flutter/services.dart';

/// Provides tools that require access to the transportation database.
/// 
/// Features include: getting lines, getting stops, checking if a journey is valid.
/// Current line is stored and all requests are made in the context of the current line, until changed.
class TransportDataBase {
  final Map<String, List<String>> _lineToStops = {};
  final Map<String, String> _stopsMap = {};
  late List<String> _lineList;
  String? _curLine;
  // paths
  static const String _LINES_DATABASE_PATH = 'assets/databases/Lines.csv';
  static const String _LINE_TO_STOP_DATABASE_PATH = 'assets/databases/lineToStops.csv';
  static const String _STOPS_DATABASE_PATH = 'assets/databases/Stops.csv';
  // Delimiters
  static const String _LINE_TO_STOP_FIELDS_DELIMITER = ',';
  static const String _STOP_CODES_DELIMITER = ';';
  static const String _STOPS_MAP_FIELDS_DELIMITER = ',';

  /// Sets the current line to [line].
  set curLine(String line) {
    _curLine = line;
  }

  /// Initializes the database resources.
  Future<void> init() async {
    await _intializeLineToStops();
    await _initializeLinesList();
    await _initializeStopsMap();
  }

  // Intializes a list of allpublic transport lines in Israel.
  Future<void> _initializeLinesList() async {
    String fileContent = await _loadDatabseIntoString(_LINES_DATABASE_PATH);
    final List<String> fields = fileContent.split('\n');
    _lineList = fields.cast<String>();   
  }

  // Intializes a map of lines to the codes of the stations it stops at.
  Future<void> _intializeLineToStops() async {
    String fileContent = await _loadDatabseIntoString(_LINE_TO_STOP_DATABASE_PATH);
    final List<String> rows = fileContent.split('\n');
    for(String row in rows){
      final List<String> fields = row.split(_LINE_TO_STOP_FIELDS_DELIMITER);
      _lineToStops[fields[0]] = fields[1].split(_STOP_CODES_DELIMITER);
    }
  }

  // Intializes a map of station codes to their names.
  Future<void> _initializeStopsMap() async{
    String fileContent = await _loadDatabseIntoString(_STOPS_DATABASE_PATH);
    final List<String> rows = fileContent.split('\n');
      for(String row in rows){
        final List<String> fields = row.split(_STOPS_MAP_FIELDS_DELIMITER);
        _stopsMap[fields[0]] = fields[1];
      }
  }

  /// Returns a list of all public transport lines in Israel.
  List<String> getLineList(){
    return _lineList;
  }

  /// Returns a list of all station the current line stops at.
  /// 
  /// List items are in the format: "station code | station name".
  /// In case the current line is not set or is invalid, returns an empty list.
  List<String> getStops() {
    if(!_lineToStops.containsKey(_curLine) || _curLine == null){
      return [];
    }
    List<String> stops = [];
    for (int i = 0; i < _lineToStops[_curLine]!.length; i++) {
      String stopCode = _lineToStops[_curLine]![i];
      stops.add("$stopCode | ${_stopsMap[stopCode]!}" );
    }
    return stops;
  }

  /// Returns if given line passes through given station.
  bool curLineStopsAtStation(String station){
    if (_curLine == '' || station == '' || !_lineList.contains(_curLine)) {return false;}
    // items are in the format: "station code | station name"
    return _lineToStops[_curLine]!.contains(station.split(' | ')[0]);
  }

  // Acceppts a path to a file and returns its content as a string.
  Future<String> _loadDatabseIntoString(String path) async{
    final data = await rootBundle.load(path);
    // deocde raw data into a readable string
    final List<int> bytes = data.buffer.asUint8List();
    return utf8.decode(bytes);
  }
}