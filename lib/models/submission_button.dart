import 'package:flutter/material.dart';
import 'package:leavo/imports/input_fields_constants.dart';

class SubmissionButton {
  static Center goButton(BuildContext context, void Function() onFormSubmit) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: SUBMISSION_MAX_WIDTH),
        margin: const EdgeInsets.only(
            top: SUBMISSION_TOP_MARGIN,
            left: SUBMISSION_SIDE_MARGIN,
            right: SUBMISSION_SIDE_MARGIN),
        decoration: submitButtonDecoration(),
        child: ElevatedButton(
          onPressed: onFormSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: SUBMISSION_BACKGROUND_COLOR,
            foregroundColor: SUBMISSION_FOREGROUND_COLOR,
            textStyle: const TextStyle(fontSize: SUBMISSION_TEXT_SIZE),
            minimumSize:
                const Size(SUBMISSION_MINIMUM_WIDTH, SUBMISSION_MINIMUM_HEIGHT),
          ),
          child: const Text(SUBMISSION_BUTTON_TEXT),
        ),
      ),
    );
  }

  static BoxDecoration submitButtonDecoration() {
    return const BoxDecoration(boxShadow: [
      BoxShadow(
        color: SHADOW_HUE,
        blurRadius: SHADOW_BLUR_RADIUS,
        spreadRadius: SHADOW_SPREAD_RADIUS,
      )
    ]);
  }
}
