import 'dart:ui';
import 'package:finandrib/customized_widgets/custom_tf.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:finandrib/screens/address_select_screen.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNo;
  final int fromScreen;
  final String userName;

  OtpVerificationScreen({this.mobileNo, this.fromScreen, this.userName});
  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  TextEditingController _otpTc = TextEditingController();
  TextEditingController _fullNameTc = new TextEditingController();
  FocusNode _fullNameFn = new FocusNode();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void dispose() {
    super.dispose();
    //_otpTc.dispose();
    _fullNameTc.dispose();
    _fullNameFn.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Text(
                'OTP Verification',
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
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      height: widget.userName == 'guest' ? 250.0 : 200.0,
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
                            Text(
                              'Enter 4 digit OTP send on your registered mobile number',
                              style: kTextStyleCalibri300.copyWith(
                                  color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            Visibility(
                              visible:
                                  widget.userName == 'guest' ? true : false,
                              child: Container(
                                width: 200.0,
                                child: CustomTF(
                                  controller: _fullNameTc,
                                  focusNode: _fullNameFn,
                                  labelText: 'Full Name',
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  capitalization: TextCapitalization.words,
                                  onSubmitted: (newValue) {},
                                ),
                              ),
                            ),
                            SizedBox(
                              height: widget.userName == 'guest' ? 10.0 : 0,
                            ),
                            Container(
                              width: 200.0,
                              child: PinCodeTextField(
                                backgroundColor: Colors.transparent,
                                controller: _otpTc,
                                keyboardType: TextInputType.number,
                                length: 4,
                                pinTheme: PinTheme(
                                    activeColor: Colors.black,
                                    inactiveColor: Colors.black,
                                    selectedColor: Colors.deepOrange,
                                    borderWidth: 1.0),
                                obscureText: false,
                                animationDuration: Duration(milliseconds: 300),
                                onChanged: (value) {},
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Calibri'),
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
                                    if (widget.userName == 'guest') {
                                      String userName = _fullNameTc.text;
                                      if (userName == '') {
                                        _showSnackBar(
                                            'Please provide your name');
                                        return;
                                      }
                                    }
                                    if (_otpTc.text.length == 4) {
                                      String fullName =
                                          widget.userName == 'guest'
                                              ? _fullNameTc.text
                                              : widget.userName;
                                      print(fullName);
                                      ProgressDialog dialog =
                                          new ProgressDialog(context);
                                      dialog.style(message: 'Logging In...');
                                      await dialog.show();
                                      NetworkResponse response =
                                          await NetworkServices
                                              .shared
                                              .verifyOtp(
                                                  phoneNo: widget.mobileNo
                                                      .replaceAll('+91', ''),
                                                  otp: _otpTc.text,
                                                  fcmToken:
                                                      dataServices.fcmToken,
                                                  userName: fullName,
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
                                      _showSnackBar('Invalid OTP');
                                    }
                                  },
                                  child: Text(
                                    'Submit',
                                    style: kTextStyleButton,
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
    });
  }
}
