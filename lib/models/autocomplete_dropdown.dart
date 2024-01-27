import 'package:flutter/material.dart';
import 'package:leavo/models/input_fields_decoration.dart';
import 'package:leavo/models/autocomplete.dart' as leavo_complete;
import 'package:leavo/imports/input_fields_constants.dart' as constants;

// Defines a search field widget with a dropdown with the Leavo app design
class AutocompleteDropdown extends StatefulWidget {
  late List<String> Function() _options;
  final String _hintText;
  final String _iconPath;
  final double _iconAlignWidth;
  final String _info;
  final String _direction;
  final ValueChanged<String> _onChange;

  /// Constructs a search field widget with a dropdown for the Leavo app
  ///
  /// [options] is the list of options that appear in the dropdown.
  /// [hintText] is the text that appears when the field is empty.
  /// [iconPath] is the path to the icon that appears on the left of the field.
  /// [iconAlignWidth] is the width of the icon in the field. Use to accommodate 
  /// for different icon sizes.
  /// [info] is the text that appears when the info button is pressed.
  /// [direction] is the direction of the text in the field. Defaults to LTR.
  /// [onChange] is the function that is called when the field is changed.
  AutocompleteDropdown({
    Key? key,
    required List<String> Function() options,
    required String hintText,
    required String iconPath,
    required double iconAlignWidth,
    required String info,
    required void Function(String) onChange,
    String direction = constants.DEFAULT_TEXT_DIRECTION,
  })  : _onChange = onChange,
        _direction = direction,
        _info = info,
        _iconAlignWidth = iconAlignWidth,
        _iconPath = iconPath,
        _hintText = hintText,
        _options = options,
        super(key: key);

  @override
  _AutocompleteDropdownState createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  // Builds the widget
  @override
  Widget build(BuildContext context) {
    LayoutBuilder layoutBuilder =
        LayoutBuilder(builder: (context, constraints) {
      return autoComplete(constraints);
    });
    return InputFieldsDecoration.outerDecoration(context, layoutBuilder);
  }

  // RawAutocomplete widget that filters options by similarity in Leavo design
  RawAutocomplete<String> autoComplete(BoxConstraints constraints) {
    return RawAutocomplete<String>(
      onSelected: onSelected,
      optionsBuilder: (TextEditingValue textEditingValue) {
        String input = textEditingValue.text;
        return input.isNotEmpty
            ? leavo_complete.Autocomplete.bestMatches(input, widget._options())
            : [];
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return _dropDown(constraints, options, context, onSelected);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return _textField(textEditingController, focusNode, context);
      },
    );
  }

  // returns a text field widget with the Leavo design
  TextFormField _textField(TextEditingController textEditingController,
      FocusNode focusNode, BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      controller: textEditingController,
      style: const TextStyle(color: Colors.black),
      onTap: () => setState(() {}),
      onTapOutside: (event) => setState(() {
        _onChangedAndUnfocus(textEditingController, focusNode);
      }),
      onEditingComplete: () => setState(() {
        _onChangedAndUnfocus(textEditingController, focusNode);
      }),
      onChanged: (str) => setState(() {
        widget._onChange(textEditingController.text);
      }),
      onFieldSubmitted: (str) => setState(() {
        _onChangedAndUnfocus(textEditingController, focusNode);
      }),
      decoration: InputFieldsDecoration.innerDecoration(
          context,
          widget._hintText,
          widget._info,
          widget._iconPath,
          widget._iconAlignWidth),
      focusNode: focusNode,
    );
  }

  // handles updating the state when an option is selected
  void onSelected(String selection) {
    setState(() {
      widget._onChange(selection);
    });
  }

  void _onChangedAndUnfocus(
      TextEditingController textEditingController, FocusNode focusNode) {
    focusNode.unfocus();
    widget._onChange(textEditingController.text);
  }

  // returns a drop down widget with the Leavo design
  Container _dropDown(BoxConstraints constraints, Iterable<String> options,
      BuildContext context, AutocompleteOnSelected<String> onSelected) {
    return Container(
      margin: const EdgeInsets.only(
          top: constants.SPACE_BETWEEN_DROPDOWN_AND_FIELD),
      constraints: const BoxConstraints(maxHeight: constants.MAX_HEIGHT),
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(constants.DROPDOWN_ROUNDNESS),
          ),
          child: _dropDownList(constraints, options, context, onSelected),
        ),
      ),
    );
  }

  // returns a drop down receptor widget with the Leavo design
  Container _dropDownList(BoxConstraints constraints, Iterable<String> options,
      BuildContext context, AutocompleteOnSelected<String> onSelected) {
    return Container(
      width: constraints.biggest.width,
      height: options.length > constants.LARGE_LIST
          ? MediaQuery.of(context).size.height /
              constants.DROPDOWN_MAX_HEIGHT_DIVIDER
          : null,
      child: ListView.builder(
        padding: const EdgeInsets.all(constants.DROPDOWN_ITEMS_SPACING),
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final String option = options.elementAt(index);
          return InkWell(
              onTap: () {
                onSelected(option);
              },
              child: _displayOption(option));
        },
      ),
    );
  }

  // displays a single option in the drop down list
  Padding _displayOption(String option) {
    return Padding(
      padding: const EdgeInsets.all(constants.DROPDOWN_SINGLE_ITEM_SPACING),
      child: Text(
        option,
        textDirection: widget._direction == constants.RTL
            ? TextDirection.rtl
            : TextDirection.ltr,
      ),
    );
  }
}
