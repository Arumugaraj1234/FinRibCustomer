import 'package:finandrib/support_files/constants.dart';
import 'package:flutter/material.dart';

import 'order_history_screen.dart';

class ErrorMessageScreen extends StatefulWidget {
  final int flag;
  ErrorMessageScreen({this.flag});
  @override
  _ErrorMessageScreenState createState() => _ErrorMessageScreenState();
}

class _ErrorMessageScreenState extends State<ErrorMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          widget.flag == 1 ? 'My Orders' : "Profile",
          style: kTextStyleAppBarTitle,
        ),
      ),
      body: Container(
        child: ErrorText(error: 'Please login to view the details'),
      ),
    );
  }
}
