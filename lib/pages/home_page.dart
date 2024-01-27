import 'package:leavo/imports/home_page_imports.dart';

/// The home page of the app where the user can select his journey details.
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state of the home page.
class _HomePageState extends State<HomePage> {
  late TransportDataBase _transportDataBase;
  String _selectedLine = DEFAULT_SELECTED_LINE;
  String _selectedStation = DEFAULT_SELECTED_STATION;
  final TextEditingController _alertController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();

// Requests android permission after the page is built
  @override
  void initState() {
    super.initState();
    _transportDataBase = TransportDataBase();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermissionForAndroid();
    });
  }

  // Builds the home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: FutureBuilder<void>(
          future: _transportDataBase.init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _inputForm(context);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  // Returns all home page input fields and the confirmation button
  ListView _inputForm(BuildContext context) {
    return ListView(physics: const NeverScrollableScrollPhysics(), children: [
      LeavoAppBar.appBar(),
      AutocompleteDropdown(
        hintText: LINE_FIELD_HINT_TEXT,
        iconPath: LINE_FIELD_ICON_PATH,
        iconAlignWidth: LINE_FIELD_ICON_ALIGN_WIDTH,
        direction: LINE_FIELD_DIRECTION,
        info: LINE_FIELD_INFO,
        options: _transportDataBase.getLineList,
        onChange: updateLine,
      ),
      AutocompleteDropdown(
        hintText: STATION_FIELD_HINT_TEXT,
        iconPath: STATION_FIELD_ICON_PATH,
        iconAlignWidth: STATION_FIELD_ICON_ALIGN_WIDTH,
        direction: STATION_FIELD_DIRECTION,
        info: STATION_FIELD_INFO,
        options: _transportDataBase.getStops,
        onChange: updateStation,
      ),
      SearchField(
        hintText: ALERT_FIELD_HINT_TEXT,
        iconPath: ALERT_FIELD_ICON_PATH,
        iconAlignWidth: ALERT_FIELD_ICON_ALIGN_WIDTH,
        inputType: ALERT_FIELD_INPUT_TYPE,
        info: ALERT_FIELD_INFO,
        controller: _alertController,
      ),
      SearchField(
        hintText: START_TIME_FIELD_HINT_TEXT,
        iconPath: START_TIME_FIELD_ICON_PATH,
        iconAlignWidth: START_TIME_FIELD_ICON_ALIGN_WIDTH,
        inputType: START_TIME_FIELD_INPUT_TYPE,
        info: START_TIME_FIELD_INFO,
        controller: _startTimeController,
      ),
      SubmissionButton.goButton(context, _onFormSubmit)
    ]);
  }

  void updateLine(String line) {
    _selectedLine = line;
    _transportDataBase.curLine = line;
  }

  void updateStation(String station) {
    _selectedStation = station;
  }

  _onFormSubmit() {
    if (_transportDataBase.curLineStopsAtStation(_selectedStation) &&
        _alertController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty) {
      Journey journey = Journey(
          line: _selectedLine,
          station: _selectedStation,
          alertTime: int.parse(_alertController.text),
          startTime: TimeTools.getNowIfAfter(_startTimeController.text));
      TimeTracker.startForegroundTask(journey, NOTIFY_NO_LINE_FOUND_AFTER);
      Navigator.push(context,MaterialPageRoute(
        builder: (context) => SearchingPage(journey: journey)),
      );
    }
  }
}
