import 'package:flutter/material.dart';
import 'package:leavo/imports/input_fields_constants.dart' as constants;
import 'package:flutter_svg/svg.dart';
import 'package:leavo/models/info_dialog.dart';

/// Handles the decoration of the input fields in accordance with the Leavo 
/// design
class InputFieldsDecoration {
  /// returns the field with external shadowing and proper placement.
  ///
  /// To be called from the build method of the widget that uses the field
  /// [context] is the context of the widget that uses the field
  /// [child] is the widget that uses the field and is to be decorated
  static Center outerDecoration(BuildContext context, Widget child) {
    return Center(
      child: Container(
          // limit the size for wide displays
          constraints: const BoxConstraints(maxWidth: constants.MAX_WIDTH),
          margin: const EdgeInsets.only(
              top: constants.TOP_MARGIN,
              left: constants.SIDE_MARGIN,
              right: constants.SIDE_MARGIN),
          decoration: _shadow(),
          child: child),
    );
  }

  /// Handles the decoration of the field itself
  ///
  /// To be called from the build method of the widget that uses the field.
  /// [context] is the context of the widget that uses the field.
  /// [hintText] is the text that appears when the field is empty.
  /// [info] is the text that appears when the info button is pressed.
  /// [iconPath] is the path to the icon that appears on the left of the field.
  /// [iconAlignWidth] is the width of the icon in the field. Use to 
  /// accommodate for different icon sizes.
  static InputDecoration innerDecoration(BuildContext context, String hintText,
      String info, String iconPath, double iconAlignWidth) {
    return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        contentPadding: EdgeInsets.zero,
        border: _inputBorder(),
        prefixIcon: _paddedPrefixIcon(iconPath, iconAlignWidth),
        suffixIcon: _separatedInfoIcon(context, info));
  }

  // returns the shadow decoration for the textField
  static BoxDecoration _shadow() {
    return const BoxDecoration(boxShadow: [
      BoxShadow(
        color: constants.SHADOW_HUE,
        blurRadius: constants.SHADOW_BLUR_RADIUS,
        spreadRadius: constants.SHADOW_SPREAD_RADIUS,
      )
    ]);
  }

  // returns the info icon
  static Container _separatedInfoIcon(BuildContext context, String info) {
    return Container(
      width: constants.INFO_ICON_CONTAINER_WIDTH,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconVerticalDivider(),
            _paddedInfoIcon(context, info),
          ],
        ),
      ),
    );
  }

  // returns the prefix icon with padding
  static Padding _paddedPrefixIcon(String iconPath, double iconAlignWidth) {
    return Padding(
      padding: EdgeInsets.only(
          right: constants.PREFIX_ICON_BASE_INSET + iconAlignWidth / 2,
          left: constants.PREFIX_ICON_BASE_INSET + iconAlignWidth / 2,
          top: constants.PREFIX_ICON_BASE_INSET,
          bottom: constants.PREFIX_ICON_BASE_INSET),
      child: _getPrefixIcon(iconPath),
    );
  }

  // returns the prefix icon
  static SvgPicture _getPrefixIcon(String iconPath) {
    return SvgPicture.asset(
      iconPath,
      height: constants.PREFIX_ICON_SIZE,
      width: constants.PREFIX_ICON_SIZE,
    );
  }

  // returns the info icon with padding
  static Padding _paddedInfoIcon(BuildContext context, String info) {
    return Padding(
      padding: const EdgeInsets.all(constants.INFO_ICON_PADDING),
      child: IconButton(
        icon: _getInfoIcon(),
        onPressed: () {
          InfoDialog.showInfoDialog(context, info);
        },
      ),
    );
  }

  // returns the info icon
  static SvgPicture _getInfoIcon() {
    return SvgPicture.asset(
      constants.INFO_ICON_PATH,
      height: constants.INFO_ICON_SIZE,
      width: constants.INFO_ICON_SIZE,
    );
  }

  // returns a vertical divider widget that is proper for the icon
  static VerticalDivider _iconVerticalDivider() {
    return const VerticalDivider(
      color: constants.VERTICAL_DIVIDER_COLOR,
      indent: constants.VERTICAL_DIVIDER_INDENT,
      endIndent: constants.VERTICAL_DIVIDER_END_INDENT,
      thickness: constants.VERTICAL_DIVIDER_THICKNESS,
    );
  }

  // returns the border widget for the textField
  static OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(constants.BORDER_RADIUS),
      borderSide: BorderSide.none,
    );
  }
}
