import 'package:leavo/imports/time_left_page_imports.dart';

/// Defined the page that shows the time left until the line arrives
class TimeLeftPage extends StatefulWidget {
  int timeLeft;
  Alert alert;
  Journey journey;

  TimeLeftPage(
      {required this.timeLeft,
      required this.alert,
      required this.journey,
      super.key});

  @override
  State<TimeLeftPage> createState() => _TimeLeftPageState();
}

class _TimeLeftPageState extends State<TimeLeftPage> {
  String minutesLeftTextSuffix = TEXT_SUFFIX;
  String _realTimeText = "";
  late Timer _timer;
  bool _canceled = false;

  /// disposes of the page resources
  @override
  void dispose() {
    widget.alert.stopAndDispose();
    _timer.cancel();
    _canceled = true;
    super.dispose();
  }

  /// Initializes the state of the page
  @override
  void initState() {
    super.initState();
    _realTimeText = widget.timeLeft.toString() + REAL_TIME_TEXT_SUFFIX;
    updateNotification(widget.timeLeft);
    _timer = _timedMinutesLeftText();
  }

  // Starts the timer that changes the minutes left text
  Timer _timedMinutesLeftText() =>
      Timer.periodic(const Duration(milliseconds: UPDATING_TIME),
          (timer) async {
        int minutesLeft = await widget.journey.getMinutesLeft();
        if (minutesLeft != Journey.NO_REAL_TIME && !_canceled) {
          _updateMinutesLeft(minutesLeft);
        } else {
          updateLinePassed();
          widget.alert.stopAlert();
          timer.cancel();
        }
      });

  // Updates the minutes left text
  void _updateMinutesLeft(int data) {
    setState(() {
      _realTimeText = data.toString() + REAL_TIME_TEXT_SUFFIX;
      updateNotification(data);
    });
  }

  // Updates the notification text
  void updateNotification(int data) {
    FlutterForegroundTask.updateService(
        notificationText: NOTIFICATION_TEXT_PREFIX +
            data.toString() +
            NOTIFICATION_TEXT_SUFFIX);
  }

  // Updates the text when the line has passed
  updateLinePassed() {
    setState(() {
      _realTimeText = "";
      minutesLeftTextSuffix = LINE_PASSED_TEXT;
    });
  }

  /// Builds the page
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.alert.stopAlert();
      },
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Container(
          margin: const EdgeInsets.all(MARGIN),
          child: _spine(),
        ),
      ),
    );
  }

  // Returns the main column of the page's widgets
  Column _spine() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: SPACE_FROM_TOP,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: _realTimeText,
                style: const TextStyle(
                    fontSize: BIG_FONT_SIZE, color: ARRIVALS_TEXT_COLOR)),
            TextSpan(
                text: minutesLeftTextSuffix,
                style: const TextStyle(
                    fontSize: BIG_FONT_SIZE, color: DEFAULT_TEXT_COLOR))
          ]))
        ]);
  }
}
