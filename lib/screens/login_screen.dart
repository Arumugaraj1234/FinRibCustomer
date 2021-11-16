import 'dart:convert';
import 'dart:ui';
import 'package:finandrib/customized_widgets/custom_tf.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/screens/login_with_password_screen.dart';
import 'package:finandrib/screens/register_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:finandrib/screens/otp_verification_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  final int fromScreen;

  LoginScreen(this.fromScreen);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode _mobileFN = FocusNode();
  TextEditingController _mobileTC = TextEditingController();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
    _mobileFN.dispose();
    _mobileTC.dispose();
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: Text(
              'Login',
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
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height:
                          MediaQuery.of(context).padding.top + kToolbarHeight,
                    ),
                    Container(
                      height: 150.0,
                      child: Center(
                        child: Image.network(
                            'https://www.finandrib.com/Images/logo.png'),
                      ),
                    ),
                    Hero(
                      tag: 'tfform',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          height: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.white38,
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
                                Container(
                                  height: 40,
                                  child: PhoneFieldHint(
                                    child: TextField(
                                      controller: _mobileTC,
                                      focusNode: _mobileFN,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      cursorColor: Colors.deepOrange,
                                      decoration: InputDecoration(
                                          labelText: 'Mobile',
                                          labelStyle:
                                              kTextStyleCalibri300.copyWith(
                                                  color: Colors.deepOrange,
                                                  fontSize: 16.0),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.deepOrange),
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          contentPadding: EdgeInsets.all(0.0)),
                                      style: kTextStyleCalibri300.copyWith(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                      onSubmitted: (newValue) {},
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Container(
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
                                      if (_mobileTC.text.length > 9 &&
                                          _mobileTC.text.length < 14) {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Logging In...');
                                        await dialog.show();
                                        String mobileNo = _mobileTC.text
                                            .replaceAll('+91', '');
                                        NetworkResponse response =
                                            await NetworkServices.shared
                                                .requestForOtp(mobileNo);
                                        await dialog.hide();
                                        if (response.code == 1) {
                                          //_showSnackBar(response.message);
                                          String name = response.data;
                                          print(name);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return OtpVerificationScreen(
                                                mobileNo: _mobileTC.text,
                                                fromScreen: widget.fromScreen,
                                                userName: name,
                                              );
                                            }),
                                          );
                                        } else if (response.code == 0) {
                                          _showSnackBar(
                                              'You are not registered with us. Please signup to login');
                                        } else {
                                          _showSnackBar(response.message);
                                        }
                                      } else {
                                        _showSnackBar(
                                            'Please provide valid mobile number');
                                      }
                                    },
                                    child: Text(
                                      'Send OTP',
                                      style: kTextStyleButton,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Text(
                                          'Or',
                                          style: kTextStyleCalibri300,
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (_mobileTC.text.length > 9 &&
                                        _mobileTC.text.length < 14) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return LoginWithPasswordScreen(
                                            mobileNo: _mobileTC.text,
                                            fromScreen: widget.fromScreen,
                                          );
                                        }),
                                      );
                                    } else {
                                      _showSnackBar(
                                          'Please provide valid mobile number');
                                    }
                                  },
                                  child: Text(
                                    'Log-In using password',
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  height: 30.0,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Don't have an account?",
                                        style: kTextStyleCalibri300.copyWith(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return RegisterScreen();
                                            }),
                                          ).then((value) {
                                            if (value == 1) {
                                              _showSnackBar(
                                                  'You have successfully registered with us');
                                            }
                                          });
                                        },
                                        child: Text(
                                          'SIGNUP',
                                          textWidthBasis: TextWidthBasis.parent,
                                          style: kTextStyleCalibriBold.copyWith(
                                              fontSize: 16),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
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
      ),
    );
  }
}

// CustomTF(
// controller: _mobileTC,
// focusNode: _mobileFN,
// labelText: 'Mobile',
// inputAction: TextInputAction.done,
// inputType: TextInputType.phone,
// capitalization: TextCapitalization.none,
// onSubmitted: (newValue) {
// print(newValue);
// },
// )
