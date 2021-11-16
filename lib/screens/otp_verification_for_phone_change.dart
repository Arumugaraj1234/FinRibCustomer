import 'dart:ui';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OtpVerificationForPhoneChange extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;

  OtpVerificationForPhoneChange({this.fullName, this.email, this.phone});

  @override
  _OtpVerificationForPhoneChangeState createState() =>
      _OtpVerificationForPhoneChangeState();
}

class _OtpVerificationForPhoneChangeState
    extends State<OtpVerificationForPhoneChange> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _otpTc = TextEditingController();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void dispose() {
    super.dispose();
    _otpTc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'OTP Verification',
          style: kTextStyleAppBarTitle,
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    height: 200.0,
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
                          Text(
                            'Enter 4 digit OTP send on your registered mobile number',
                            textAlign: TextAlign.center,
                            style: kTextStyleCalibri300.copyWith(
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            width: 200.0,
                            child: PinCodeTextField(
                              backgroundColor: Colors.transparent,
                              controller: _otpTc,
                              textInputType: TextInputType.number,
                              length: 4,
                              pinTheme: PinTheme(
                                  activeColor: Colors.black,
                                  inactiveColor: Colors.black,
                                  selectedColor: Colors.deepOrange,
                                  borderWidth: 1.0),
                              obsecureText: false,
                              animationDuration: Duration(milliseconds: 300),
                              onChanged: (value) {},
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
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
                                  if (_otpTc.text.length == 4) {
                                    ProgressDialog dialog =
                                        new ProgressDialog(context);
                                    dialog.style(message: 'Please wait...');
                                    await dialog.show();
                                    NetworkResponse response =
                                        await NetworkServices
                                            .shared
                                            .verifyOtpToResetMobileNo(
                                                otp: _otpTc.text,
                                                mobileNo: widget.phone,
                                                name: widget.fullName,
                                                email: widget.email,
                                                context: context);
                                    if (response.code == 1) {
                                      Navigator.pop(context);
                                    } else {
                                      _showSnackBar(response.message);
                                    }
                                  } else {
                                    _showSnackBar("Invalid Otp");
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style: kTextStyleCalibriBold.copyWith(
                                      fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
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
