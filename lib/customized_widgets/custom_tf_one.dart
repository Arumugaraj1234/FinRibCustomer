import 'package:finandrib/support_files/constants.dart';
import 'package:flutter/material.dart';

class CustomTFOne extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction inputAction;
  final TextCapitalization capitalization;
  final Function onSubmitted;
  final TextInputType inputType;
  final String labelText;

  CustomTFOne(
      {@required this.controller,
      @required this.focusNode,
      @required this.labelText,
      this.inputAction,
      this.capitalization,
      this.onSubmitted,
      this.inputType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      autofocus: false,
      textInputAction: inputAction,
      textCapitalization: capitalization,
      onSubmitted: onSubmitted,
      keyboardType: inputType,
      cursorColor: Colors.deepOrange,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: kTextStyleCalibri300.copyWith(
              color: focusNode.hasFocus ? Colors.deepOrange : Colors.grey,
              fontSize: 16.0),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          contentPadding: EdgeInsets.all(0.0)),
      style: kTextStyleCalibri300.copyWith(
        color: Colors.black,
        fontSize: 16.0,
      ),
    );
  }
}
