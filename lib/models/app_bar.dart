import 'package:flutter/material.dart';
import 'package:leavo/imports/leavo_constants.dart';

/// Defines AppBar widget for the Leavo app
class LeavoAppBar {
  static const double _APP_BAR_HEIGHT = 100.0;
  static const double _APP_BAR_ELEVATION = 0.0;

  /// AppBar widget with title that conforms to the app's theme
  static AppBar appBar() {
    return AppBar(
      title: _appBarTitle(),
      centerTitle: true,
      toolbarHeight: _APP_BAR_HEIGHT,
      backgroundColor: BACKGROUND_COLOR,
      elevation: _APP_BAR_ELEVATION,
    );
  }

  // Returns the title of the app bar
  static Text _appBarTitle() {
    return const Text(
      APP_NAME_UPPERCASE,
      style: TextStyle(
          color: Colors.black,
          fontSize: TITLE_SIZE,
          fontWeight: FontWeight.bold),
    );
  }
}
