import 'dart:convert';
import 'package:finandrib/customized_widgets/profile_tf.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_verification_for_phone_change.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _firstNameTC = new TextEditingController();
  TextEditingController _emailTC = new TextEditingController();
  TextEditingController _mobileTC = new TextEditingController();
  FocusNode _firstNameFN = new FocusNode();
  FocusNode _emailFN = new FocusNode();
  FocusNode _mobileFN = new FocusNode();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    setProfileDetails();
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void setProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDetailsString = prefs.getString(kUserDetailsKey);
    if (userDetailsString != null) {
      Map<String, dynamic> userDetails = jsonDecode(userDetailsString);

      String name = userDetails['name'];
      String email = userDetails['email'];
      String phone = userDetails['mobileNo'];

      _firstNameTC.text = name;
      _emailTC.text = email;
      _mobileTC.text = phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Profile',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        child: Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ProfileTF(
                                  controller: _firstNameTC,
                                  focusNode: _firstNameFN,
                                  labelText: 'Full Name',
                                  inputAction: TextInputAction.next,
                                  capitalization: TextCapitalization.words,
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_emailFN);
                                  },
                                  inputType: TextInputType.name,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                ProfileTF(
                                  controller: _emailTC,
                                  focusNode: _emailFN,
                                  labelText: 'Email',
                                  inputAction: TextInputAction.next,
                                  capitalization: TextCapitalization.none,
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_mobileFN);
                                  },
                                  inputType: TextInputType.emailAddress,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                ProfileTF(
                                  controller: _mobileTC,
                                  focusNode: _mobileFN,
                                  labelText: 'Mobile',
                                  inputAction: TextInputAction.done,
                                  capitalization: TextCapitalization.none,
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  inputType: TextInputType.phone,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Updating...');
                    await dialog.show();
                    NetworkResponse response = await NetworkServices.shared
                        .updateProfile(
                            fullName: _firstNameTC.text,
                            email: _emailTC.text,
                            phone: _mobileTC.text,
                            context: context);
                    await dialog.hide();
                    if (response.code == 1) {
                      _showSnackBar(response.message);
                    } else if (response.code == 2) {
                      _showSnackBar(response.message);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (context) {
                          return OtpVerificationForPhoneChange(
                            fullName: _firstNameTC.text,
                            email: _emailTC.text,
                            phone: _mobileTC.text,
                          );
                        }),
                      );
                    } else {
                      _showSnackBar(response.message);
                    }
                  },
                  child: Container(
                    height: 40.0,
                    color: Colors.deepOrange,
                    child: Center(
                      child: Text(
                        'Update',
                        style: kTextStyleCalibriBold.copyWith(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
