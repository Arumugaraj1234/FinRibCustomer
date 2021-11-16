import 'package:flutter/material.dart';

class AddressTF extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction inputAction;
  final TextCapitalization capitalization;
  final Function onSubmitted;
  final TextInputType inputType;
  final String labelText;
  final Function onChanged;
  final bool hasFocus;

  AddressTF(
      {@required this.controller,
      @required this.focusNode,
      @required this.labelText,
      this.inputAction,
      this.capitalization,
      this.onSubmitted,
      this.inputType,
      this.onChanged,
      this.hasFocus});

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
      cursorColor: Colors.orange,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
              color: focusNode.hasFocus ? Colors.deepOrange : Colors.black,
              fontFamily: 'Calibri'),
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
      style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
          fontFamily: 'Calibri'),
      onChanged: onChanged,
    );
  }
}
