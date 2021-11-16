import 'package:flutter/material.dart';

class CustomTF extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction inputAction;
  final TextCapitalization capitalization;
  final Function onSubmitted;
  final TextInputType inputType;
  final String labelText;

  CustomTF(
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
          labelStyle: TextStyle(
            fontFamily: 'Calibri',
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
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
          fontFamily: 'Calibri',
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: Colors.white),
    );
  }
}
