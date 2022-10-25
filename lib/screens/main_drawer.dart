import 'dart:convert';
import 'package:finandrib/screens/category_screen.dart';
import 'package:finandrib/screens/home_screen.dart';
import 'package:finandrib/screens/login_one_screen.dart';
import 'package:finandrib/screens/rewards_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:finandrib/screens/aboutus_screen.dart';
import 'package:finandrib/screens/faq_screen.dart';
import 'package:finandrib/screens/terms_conditions_screen.dart';
import 'package:finandrib/screens/contacts_screen.dart';
import 'package:finandrib/screens/login_screen.dart';

class MainDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final DataServices services;

  MainDrawer({this.isLoggedIn, this.services});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(child: Image.asset('images/logo1.png')),
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    Visibility(
                      visible: true,
                      child: Container(
                        height: 40.0,
                        child: ListTile(
                          leading: Icon(
                            Icons.home,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            'Home',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return CategoryScreen(
                                  shops: services.allShops,
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLoggedIn,
                      child: Container(
                        height: 40.0,
                        child: ListTile(
                          leading: Icon(
                            Icons.local_offer,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            'Rewards',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RewardsScreen();
                                },
                                settings: RouteSettings(name: 'ProfileScreen'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLoggedIn,
                      child: Container(
                        height: 40.0,
                        child: ListTile(
                          leading: Icon(
                            Icons.share,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            'Invite Friend',
                          ),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String userDetailsString =
                                prefs.getString(kUserDetailsKey);
                            Map<String, dynamic> userDetails =
                                jsonDecode(userDetailsString);
                            String referralCode = userDetails['referralCode'];

                            Share.share(
                                'Share this app with your friend and get reward of INR 50 in your account by redeem the referral code $referralCode');
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: ListTile(
                        leading: Icon(
                          Icons.info,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          'About us',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return AboutUsScreen();
                          }));
                        },
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: ListTile(
                        leading: Icon(
                          Icons.question_answer,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          'FAQ',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return FAQScreen();
                          }));
                        },
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          'Terms and Conditions',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return TermsConditionScreen();
                          }));
                        },
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          'Support',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return ContactsScreen();
                          }));
                        },
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Container(
                        height: 40.0,
                        child: ListTile(
                          leading: Icon(
                            FontAwesomeIcons.signOutAlt,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            'Logout',
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                'V1.23.0', //TEST VERSION 2.0 //todo: change the version while going to live
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 50.0,
              color: Colors.deepOrange,
              child: InkWell(
                onTap: () {
                  if (isLoggedIn) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return WillPopScope(
                            onWillPop: () {},
                            child: new AlertDialog(
                              title: new Text('Logout!'),
                              content:
                                  new Text('Are you sure you want logout?'),
                              actions: <Widget>[
                                new FlatButton(
                                  onPressed: () async {
                                    NetworkServices.shared.logout(context);
                                    Navigator.pop(context);
                                  },
                                  child: new Text('Yes'),
                                ),
                                new FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: new Text('No'),
                                ),
                              ],
                            ),
                          );
                        });
                  } else {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) {
                        return LoginScreen(1);
                        // return LoginOneScreen(
                        //   fromScreen: 1,
                        // );
                      }),
                    );
                  }
                },
                child: Container(
                  height: 50.0,
                  child: ListTile(
                    trailing: Icon(
                      isLoggedIn
                          ? FontAwesomeIcons.signOutAlt
                          : FontAwesomeIcons.signInAlt,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    title: Text(
                      isLoggedIn ? 'Log Out' : 'LogIn',
                      style: TextStyle(
                          fontFamily: 'Calibri',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
