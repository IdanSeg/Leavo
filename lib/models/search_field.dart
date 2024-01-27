import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:leavo/models/time_tools.dart';
import 'package:leavo/models/input_fields_decoration.dart';
import 'package:leavo/imports/input_fields_constants.dart' as constants;

/// Defines a search field widget for the Leavo app
class SearchField extends StatefulWidget {
  final String _hintText;
  final String _iconPath;
  final double _iconAlignWidth;
  final String _info;
  final String _inputType;
  final String _direction;
  final TextEditingController? _controller;
  final void Function(String)? _onChanged;

  /// Constants for the input type
  static const String ANY_INPUT = 'any';
  static const String TIME_INPUT = 'Time';
  static const String INTEGER_INPUT = 'Integer';

  /// Creates a Leavo search field widget
  ///
  /// [hintText] is the text that appears when the field is empty.
  /// [iconPath] is the path to the icon that appears on the left of the field.
  /// [iconAlignWidth] is the width of the icon in the field. Use to accommodate 
  /// for different icon sizes.
  /// [inputType] is the type of input that the field accepts. Options: 'Any', 
  /// 'Time', 'Integer'.
  /// Selecting time will open a time picker when the field is pressed.
  /// [info] is the text that appears when the info button is pressed.
  /// [direction] is the direction of the text in the field. Defaults to LTR.
  /// [controller] is the controller of the field. Defaults to null.
  /// [onChanged] is the function that is called when the field is changed. 
  /// Defaults to null.
  const SearchField(
      {required String hintText,
      required String iconPath,
      required double iconAlignWidth,
      required String info,
      String inputType = ANY_INPUT,
      String direction = constants.DEFAULT_TEXT_DIRECTION,
      TextEditingController? controller,
      void Function(String)? onChanged})
      : _onChanged = onChanged,
        _controller = controller,
        _direction = direction,
        _inputType = inputType,
        _info = info,
        _iconAlignWidth = iconAlignWidth,
        _iconPath = iconPath,
        _hintText = hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();

  get controller => _controller;
  get onChanged => _onChanged;
}

class _SearchFieldState extends State<SearchField> {
  // flag for wheter to set the current time as the field's text
  bool setAsCurrentTime = true;

  @override
  Widget build(BuildContext context) {
    if (setAsCurrentTime && widget._inputType == SearchField.TIME_INPUT) {
      widget._controller?.text = TimeOfDay.now().format(context);
    }
    TextField textField = _textFieldSetUp(context);
    return InputFieldsDecoration.outerDecoration(context, textField);
  }

  // returns a set-up textField
  TextField _textFieldSetUp(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      keyboardType: widget._inputType == SearchField.INTEGER_INPUT
          ? TextInputType.number
          : null,
      controller: widget._controller,
      onTap: widget._inputType == SearchField.TIME_INPUT
          ? () => _selectTime(context)
          : null,
      inputFormatters: widget._inputType == SearchField.INTEGER_INPUT
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      style: const TextStyle(
        color: Colors.black,
      ),
      decoration: InputFieldsDecoration.innerDecoration(
          context,
          widget._hintText,
          widget._info,
          widget._iconPath,
          widget._iconAlignWidth),
      onChanged: widget._onChanged,
    );
  }

  // opens a time picker and sets the selected time as the field's text
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _onTimeSelected(pickedTime);
    }
  }

  // sets the given time as the field's text
  void _onTimeSelected(TimeOfDay pickedTime) {
    setState(() {
      DateTime pickedTimeInDateTime =
          TimeTools.turnToDateTime(pickedTime.hour, pickedTime.minute);
      String time = DateFormat.Hm().format(pickedTimeInDateTime);
      widget._controller?.text = time;
      setAsCurrentTime = false;
    });
  }
}
