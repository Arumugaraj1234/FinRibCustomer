import 'dart:ui';
import 'package:finandrib/customized_widgets/custom_tf.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:sms_autofill/sms_autofill.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FocusNode _nameFN = FocusNode();
  FocusNode _mobileFN = FocusNode();
  FocusNode _emailFN = FocusNode();
  FocusNode _passwordFN = FocusNode();
  FocusNode _confirmPasswordFN = FocusNode();
  TextEditingController _nameTC = TextEditingController();
  TextEditingController _mobileTC = TextEditingController();
  TextEditingController _emailTC = TextEditingController();
  TextEditingController _passwordTC = TextEditingController();
  TextEditingController _confirmPasswordTC = TextEditingController();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  String isValidForRegister(
      {String name,
      String mobileNo,
      String email,
      String password,
      String confirmPassword}) {
    if (name.length < 1) {
      return 'Please provide a valid name';
    } else if (mobileNo.length < 9 || mobileNo.length > 13) {
      return 'Please provide a valid mobile number';
    } else if (validateEmail(email) == false) {
      return 'Please provide a valid email address';
    } else if (password.length < 6) {
      return 'Password should be min. 6 charactors';
    } else if (password != confirmPassword) {
      return 'Password & Confirm password should be the same';
    }
    return '';
  }

  @override
  void dispose() {
    super.dispose();
    _nameFN.dispose();
    _mobileFN.dispose();
    _emailFN.dispose();
    _passwordFN.dispose();
    _confirmPasswordFN.dispose();
    _nameTC.dispose();
    _mobileTC.dispose();
    _emailTC.dispose();
    _passwordTC.dispose();
    _confirmPasswordTC.dispose();
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
              'Sign Up',
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
                          'https://www.finandrib.com/Images/logo.png'),
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
                              CustomTF(
                                controller: _nameTC,
                                focusNode: _nameFN,
                                labelText: 'Full Name',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (newValue) {
                                  FocusScope.of(context)
                                      .requestFocus(_mobileFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              // PhoneFieldHint(
                              //   child: TextField(
                              //     focusNode: _mobileFN,
                              //     controller: _mobileTC,
                              //     autofocus: false,
                              //     textInputAction: TextInputAction.next,
                              //     textCapitalization: TextCapitalization.none,
                              //     onSubmitted: onSubmitted,
                              //     keyboardType: inputType,
                              //     cursorColor: Colors.deepOrange,
                              //     decoration: InputDecoration(
                              //         labelText: labelText,
                              //         labelStyle: TextStyle(
                              //           fontFamily: 'Calibri',
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w300,
                              //         ),
                              //         enabledBorder: UnderlineInputBorder(
                              //           borderSide:
                              //               BorderSide(color: Colors.black),
                              //         ),
                              //         focusedBorder: UnderlineInputBorder(
                              //           borderSide: BorderSide(
                              //               color: Colors.deepOrange),
                              //         ),
                              //         border: UnderlineInputBorder(
                              //           borderSide:
                              //               BorderSide(color: Colors.black),
                              //         ),
                              //         contentPadding: EdgeInsets.all(0.0)),
                              //     style: TextStyle(
                              //         fontFamily: 'Calibri',
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.w300,
                              //         color: Colors.white),
                              //   ),
                              // ),
                              CustomTF(
                                controller: _mobileTC,
                                focusNode: _mobileFN,
                                labelText: 'Mobile',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.phone,
                                capitalization: TextCapitalization.none,
                                onSubmitted: (newValue) {
                                  FocusScope.of(context).requestFocus(_emailFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTF(
                                controller: _emailTC,
                                focusNode: _emailFN,
                                labelText: 'Email',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.emailAddress,
                                capitalization: TextCapitalization.none,
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
                                      String errorMsg = isValidForRegister(
                                          name: _nameTC.text,
                                          mobileNo: _mobileTC.text,
                                          email: _emailTC.text,
                                          password: _passwordTC.text,
                                          confirmPassword:
                                              _confirmPasswordTC.text);
                                      if (errorMsg == '') {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Registering...');
                                        await dialog.show();
                                        NetworkResponse response =
                                            await NetworkServices.shared
                                                .registerNewUser(
                                                    name: _nameTC.text,
                                                    phoneNo: _mobileTC.text,
                                                    email: _emailTC.text,
                                                    regFrom: 1,
                                                    uid: '',
                                                    password:
                                                        _confirmPasswordTC.text,
                                                    context: context);
                                        await dialog.hide();
                                        if (response.code == 2) {
                                          Navigator.pop(context, 1);
                                        } else {
                                          _showSnackBar(response.message);
                                        }
                                      } else {
                                        _showSnackBar(errorMsg);
                                      }
                                    },
                                    child: Text('SIGN UP',
                                        style: kTextStyleButton),
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
