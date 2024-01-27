import 'package:flutter/material.dart';

/// Defines a pop up dialog box with a close button.
class InfoDialog {
  static const double _BACKGROUND_OPACITY = 0.5;
  static const Color _BACKGROUND_COLOR = Colors.white;
  static const int _TRANSITION_DURATION_MS = 200;
  static const double _DIALOG_WIDTH = 320;
  static const double _DIALOG_HEIGHT = 140;
  static const double _FONT_SIZE = 15;
  static const String _FONT_FAMILY = 'Arial';
  static const Color _FONT_COLOR = Colors.black;
  static const double _SPACE_FROM_CLOSE_BUTTON = 5;
  static const String _CLOSE_BUTTON_TEXT = 'Close';

  /// Shows a pop up dialog box with the given text and a close button.
  /// 
  /// [text] is the text to be displayed in the pop up dialog box.
  static Future<Object?> showInfoDialog(BuildContext context, String text) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(_BACKGROUND_OPACITY),
      transitionDuration: const Duration(milliseconds: _TRANSITION_DURATION_MS),
      pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) =>
          _content(buildContext, animation, secondaryAnimation, text, context),
    );
  }

  // Returns the content of the pop up dialog box.
  static Center _content(BuildContext buildContext, Animation animation,
      Animation secondaryAnimation, String text, BuildContext context) {
    return Center(
      child: Container(
        width: _DIALOG_WIDTH,
        height: _DIALOG_HEIGHT,
        color: _BACKGROUND_COLOR,
        child: _contentSpine(text, context),
      ),
    );
  }

  // Returns a column ordered with the pop up content.
  static Column _contentSpine(String text, BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _infoText(text),
          const SizedBox(
            height: _SPACE_FROM_CLOSE_BUTTON,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(_CLOSE_BUTTON_TEXT),
          ),
        ],
      );
  }
  // Returns the info text in a displayable format.
  static Text _infoText(String text) {
    return Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: _FONT_SIZE,
              fontFamily: _FONT_FAMILY,
              color: _FONT_COLOR,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
          );
  }
}
