import 'package:leavo/imports/searching_page_imports.dart';

class SearchingPage extends StatefulWidget {
  final Journey journey;
  SearchingPage({super.key, required this.journey});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  var _index = STARTING_INDEX;
  late Timer _timer;
  List<int> nextArrivals = [];
  bool cancelled = false;
  late Alert alert;

  @override

  /// Initializes the state of the page
  void initState() {
    super.initState();
    _timer = _timedWaitingText();
    alert = Alert(
        whenMatch: navigateToTimeLeftPage,
        trackingPassed: showTrackingTimePassedAlert);
  }

  void navigateToTimeLeftPage(int timeLeft) {
    //set last real time to time left
    widget.journey.lastRealTime(timeLeft);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TimeLeftPage(
                timeLeft: timeLeft, alert: alert, journey: widget.journey)));
  }

  void showTrackingTimePassedAlert() {
    InfoDialog.showInfoDialog(context, TRACKING_TIME_PASSED_INFO);
  }

  // Starts the timer that changes the waiting text
  Timer _timedWaitingText() =>
      Timer.periodic(const Duration(milliseconds: WAITING_TEXT_SPEED),
          (timer) async {
        nextArrivals = List<int>.from(await widget.journey.getRealTime());
        if (!cancelled) {
          setState(() {
            _index = (_index + 1) % WAITING_TEXTS.length;
          });
        }
      });

  @override
  void dispose() {
    alert.dispose();
    _timer.cancel();
    cancelled = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Container(
        margin: const EdgeInsets.all(MARGIN),
        child: _spine(),
      ),
    );
  }

  // Returns the spine of the page
  Column _spine() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: SPACE_FROM_TOP,
          ),
          _waitingText(),
          const SizedBox(height: ARRIVALS_AND_WAITING_SPACE),
          _nextArrivalsText(),
          const SizedBox(
            height: FYI_AND_ARRIVALS_SPACE,
          ),
          const Text(FYI_TEXT,
              style: TextStyle(
                  fontSize: MINOR_FONT_SIZE, color: DEFAULT_TEXT_COLOR)),
        ]);
  }

  // Returns the waiting text
  Text _waitingText() {
    return Text(WAITING_TEXTS[_index],
        style: const TextStyle(
            fontSize: BIG_FONT_SIZE,
            color: DEFAULT_TEXT_COLOR,
            fontWeight: FontWeight.bold));
  }

  // Returns the next arrivals text
  Widget _nextArrivalsText() {
    if (nextArrivals.isNotEmpty &&
        !nextArrivals.contains(Journey.NO_REAL_TIME)) {
      return _textWhenArrivalsExist();
    } else {
      return Text(NO_ARRIVALS_TEXT, style: defaultTextStyle());
    }
  }

  // Returns the text for when arrivals exist
  RichText _textWhenArrivalsExist() {
    return RichText(
        text: TextSpan(children: [
      TextSpan(text: NEXT_ARRIVALS_PREFIX_TEXT, style: defaultTextStyle()),
      _getNextArrivalsText(),
      TextSpan(text: NEXT_ARRIVALS_SUFFIX_TEXT, style: defaultTextStyle())
    ]));
  }

  // Returns the text of the next arrivals themselves
  TextSpan _getNextArrivalsText() {
    var textSpan = TextSpan(
      text: nextArrivals
          .take(NUMBER_OF_ARRIVALS_TO_SHOW)
          .map((arrival) => arrival.toString())
          .join(ARRIVAL_TIMES_SEPARATOR),
      style: greenTextStyle(),
    );
    return textSpan;
  }

  TextStyle greenTextStyle() {
    return const TextStyle(fontSize: MID_FONT_SIZE, color: ARRIVALS_TEXT_COLOR);
  }

  TextStyle defaultTextStyle() {
    return const TextStyle(fontSize: MID_FONT_SIZE, color: DEFAULT_TEXT_COLOR);
  }
}
