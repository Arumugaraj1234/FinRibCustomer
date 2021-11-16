import 'dart:ui';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:finandrib/screens/forget_password_screen.dart';
import 'package:provider/provider.dart';

import 'address_select_screen.dart';

class LoginWithPasswordScreen extends StatefulWidget {
  final String mobileNo;
  final int fromScreen;

  LoginWithPasswordScreen({this.mobileNo, this.fromScreen});
  @override
  _LoginWithPasswordScreenState createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen> {
  FocusNode _passwordFN = FocusNode();
  TextEditingController _passwordTC = TextEditingController();
  bool _isSecureText = true;
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void dispose() {
    _passwordFN.dispose();
    _passwordTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
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
                                Container(
                                  height: 50,
                                  child: TextField(
                                    controller: _passwordTC,
                                    focusNode: _passwordFN,
                                    keyboardType: TextInputType.text,
                                    obscureText: _isSecureText,
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.deepOrange,
                                    decoration: InputDecoration(
                                        suffix: IconButton(
                                            icon: Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              setState(() {
                                                _isSecureText = !_isSecureText;
                                              });
                                            }),
                                        labelText: 'Password',
                                        labelStyle:
                                            kTextStyleCalibri300.copyWith(
                                                color: _passwordFN.hasFocus
                                                    ? Colors.deepOrange
                                                    : Colors.white,
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
                                      if (_passwordTC.text.length > 5) {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Logging In...');
                                        await dialog.show();
                                        NetworkResponse response =
                                            await NetworkServices
                                                .shared
                                                .loginWithPassword(
                                                    phoneNo: widget.mobileNo
                                                        .replaceAll('+91', ''),
                                                    password: _passwordTC.text,
                                                    fcmToken:
                                                        dataServices.fcmToken,
                                                    context: context);
                                        await dialog.hide();

                                        if (response.code == 1) {
                                          if (widget.fromScreen == 1) {
                                            Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    'HomeScreen'));
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return AddressSelectScreen(
                                                    shopId: dataServices
                                                        .selectedShop.id,
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                        } else {
                                          _showSnackBar(response.message);
                                        }
                                      } else {
                                        _showSnackBar(
                                            'The password length must be minimum 6 characters');
                                      }
                                    },
                                    child:
                                        Text('Login', style: kTextStyleButton),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    ProgressDialog dialog =
                                        new ProgressDialog(context);
                                    dialog.style(message: 'Logging In...');
                                    await dialog.show();
                                    NetworkResponse response =
                                        await NetworkServices
                                            .shared
                                            .requestForOtp(widget.mobileNo
                                                .replaceAll('+91', ''));
                                    await dialog.hide();
                                    if (response.code == 1) {
                                      _showSnackBar(response.message);
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ForgetPasswordScreen(
                                          mobileNo: widget.mobileNo,
                                        );
                                      }));
                                    } else {
                                      _showSnackBar(response.message);
                                    }
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    textWidthBasis: TextWidthBasis.parent,
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 14),
                                  ),
                                ),
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
      );
    });
  }
}
