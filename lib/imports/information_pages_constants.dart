// ignore_for_file: constant_identifier_names

import 'dart:ui';

// general
const double MARGIN = 22;
const Color DEFAULT_TEXT_COLOR = Color.fromARGB(255, 107, 160, 238);
const double BIG_FONT_SIZE = 42;
const double MID_FONT_SIZE = 30;
const double MINOR_FONT_SIZE = 18;


// searching page
const Color ARRIVALS_TEXT_COLOR = Color.fromARGB(255, 32, 195, 111);
const List<String> WAITING_TEXTS = [
  'Searching',
  'Searching.',
  'Searching..',
  'Searching...'
];
const int WAITING_TEXT_SPEED = 900;
const int STARTING_INDEX = 0;
const String TRACKING_TIME_PASSED_INFO =
    "Could not find a match yet. You may want to check manually or "
    "update the search.";
const double SPACE_FROM_TOP = 150;
const double ARRIVALS_AND_WAITING_SPACE = 25;
const double FYI_AND_ARRIVALS_SPACE = 25;
const String NEXT_ARRIVALS_PREFIX_TEXT = "Next arrivals: ";
const String NEXT_ARRIVALS_SUFFIX_TEXT = " minutes.";
const String NO_ARRIVALS_TEXT = "No real time is available yet.";
const int NUMBER_OF_ARRIVALS_TO_SHOW = 3;
const String ARRIVAL_TIMES_SEPARATOR = ", ";
const String FYI_TEXT = "Keep the app in the background,\n"
    "and we'll let you know when it's time.";

// time left page
 const String TEXT_SUFFIX = "until your line arrives.";
 const String REAL_TIME_TEXT_SUFFIX = " minutes ";
 const String LINE_PASSED_TEXT =
      "The line has passed or lost connection.";
 const int UPDATING_TIME = 10000;
 const String NOTIFICATION_TEXT_PREFIX = "Your line is arriving in ";
 const String NOTIFICATION_TEXT_SUFFIX = " minutes";
 const double TIME_LEFT_SPACE_FROM_TOP = 150;