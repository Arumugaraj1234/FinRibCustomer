import 'dart:ui';
import 'package:finandrib/customized_widgets/custom_tf.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final String mobileNo;

  ForgetPasswordScreen({this.mobileNo});
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  FocusNode _otpFN;
  FocusNode _passwordFN;
  FocusNode _confirmPasswordFN;
  TextEditingController _otpTC;
  TextEditingController _passwordTC;
  TextEditingController _confirmPasswordTC;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  String isValidForChangePassword(
      {String otp, String password, String confirmPassword}) {
    if (otp.length != 4) {
      return 'Please provide a valid otp';
    } else if (password.length < 6) {
      return 'Password should be min. 6 characters';
    } else if (password != confirmPassword) {
      return 'Password & Confirm password should be the same';
    }
    return '';
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void initState() {
    super.initState();
    _otpFN = FocusNode();
    _passwordFN = FocusNode();
    _confirmPasswordFN = FocusNode();
    _otpTC = TextEditingController();
    _passwordTC = TextEditingController();
    _confirmPasswordTC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _otpFN.dispose();
    _passwordFN.dispose();
    _confirmPasswordFN.dispose();
    _otpTC.dispose();
    _confirmPasswordTC.dispose();
    _passwordTC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: Text(
              'Forget Password',
              style: kTextStyleAppBarTitle,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new ExactAssetImage('images/bgImg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.white.withOpacity(0.0),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).padding.top + kToolbarHeight,
                  ),
                  Container(
                    height: 150.0,
                    child: Center(
                      child: Image.network(
                          'https://finandrib.com/image/catalog/logo/logo.png'),
                    ),
                  ),
                  Hero(
                    tag: 'tfform',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        height: 360.0,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CustomTF(
                                controller: _otpTC,
                                focusNode: _otpFN,
                                labelText: 'Otp',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (newValue) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTF(
                                controller: _passwordTC,
                                focusNode: _passwordFN,
                                labelText: 'Password',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.none,
                                onSubmitted: (newValue) {
                                  FocusScope.of(context)
                                      .requestFocus(_confirmPasswordFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTF(
                                controller: _confirmPasswordTC,
                                focusNode: _confirmPasswordFN,
                                labelText: 'Confirm Password',
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.none,
                                onSubmitted: (newValue) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Flexible(
                                child: Container(
                                  height: 40.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      String errorMsg =
                                          isValidForChangePassword(
                                              otp: _otpTC.text,
                                              password: _passwordTC.text,
                                              confirmPassword:
                                                  _confirmPasswordTC.text);
                                      if (errorMsg == '') {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Logging In...');
                                        await dialog.show();
                                        NetworkResponse response =
                                            await NetworkServices.shared
                                                .changePassword(
                                                    mobileNo: widget.mobileNo
                                                        .replaceAll('+91', ''),
                                                    otp: _otpTC.text,
                                                    newPassword:
                                                        _passwordTC.text);
                                        await dialog.hide();
                                        if (response.code == 1) {
                                          //_showSnackBar(response.message);
                                          Navigator.pop(context);
                                        } else {
                                          _showSnackBar(response.message);
                                        }
                                      } else {
                                        _showSnackBar(errorMsg);
                                      }
                                    },
                                    child: Text(
                                      'SIGN UP',
                                      style: kTextStyleButton,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
//                  Expanded(
//                    child: Container(),
//                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
