import 'dart:convert';

import 'package:finandrib/models/init_settings.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/screens/error_screen.dart';
import 'package:finandrib/screens/home_screen.dart';
import 'package:finandrib/screens/initial_instruction_screen.dart';
import 'package:finandrib/screens/location_error_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show InternetAddress, Platform, SocketException;
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('On Message: $message');
      String title = message['notification']['title'];
      String content = message['notification']['body'];
      _showNotification(0, title, content, '');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('On Launch Message: $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('On Resume Message: $message');
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    //_firebaseMessaging.getToken().then((token) => print(token));
    print('Fire base one');
    _firebaseMessaging.getToken().then((token) {
      print('FCM TOKEN: $token');
      Provider.of<DataServices>(context, listen: false).setFcmToken(token);
    });
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _init();
  }

  Future<dynamic> onSelectNotification(String payload) async {
    /*Do whatever you want to do on notification click. In this case, I'll show an alert dialog*/
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(payload),
        content: Text("Payload: $payload"),
      ),
    );
  }

  Future<void> _showNotification(
    int notificationId,
    String notificationTitle,
    String notificationContent,
    String payload, {
    String channelId = '1234',
    String channelTitle = 'Android Channel',
    String channelDescription = 'Default Android Channel for notifications',
    Priority notificationPriority = Priority.High,
    Importance notificationImportance = Importance.Max,
  }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription,
      playSound: false,
      importance: notificationImportance,
      priority: notificationPriority,
    );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _init() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(seconds: 3), () {
      _getSharedPreferenceDetails();
      _getInitSettings();
    });
  }

  void _getSharedPreferenceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUserLoggedIn = prefs.getBool(kUserLoggedInKey);
    int userId = prefs.getInt(kUserIdKey);
    String userDetailsString = prefs.getString(kUserDetailsKey);
    print(
        'UserLoggedInStatus: $isUserLoggedIn, UserId: $userId, UserDetails: $userDetailsString');
    if (isUserLoggedIn != null) {
      Provider.of<DataServices>(context, listen: false)
          .setUserLoggedInStatus(isUserLoggedIn);
    }

    if (userId != null) {
      Provider.of<DataServices>(context, listen: false).setUserId(userId);
    }

    if (userDetailsString != null) {
      Map<String, dynamic> userDetails = jsonDecode(userDetailsString);

      String name = userDetails['name'];
      String email = userDetails['email'];
      String phone = userDetails['mobileNo'];
      String referralCode = userDetails['referralCode'];

      Map<String, String> userDetailsa = {
        'name': name,
        'email': email,
        'mobileNo': phone,
        'referralCode': referralCode
      };
      Provider.of<DataServices>(context, listen: false)
          .setUserDetails(userDetailsa);
    }
  }

  void _getInitSettings() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        NetworkResponse response =
            await NetworkServices.shared.getInitSettings(context);
        if (response.code == 1) {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          double currentVersion = kCurrentVersion;
          InitSettings initSettings = response.data;
          double latestVersion = initSettings.latestVersion;
          print(latestVersion);
          bool isNewVersionAvailable =
              (currentVersion < latestVersion) ? true : false;
          if (isNewVersionAvailable) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return InitialInstructionScreen(
                  settings: initSettings,
                );
              }),
            );
          } else {
            var geoLocator = Geolocator();
            var status = await geoLocator.checkGeolocationPermissionStatus();
            print('Location Status: $status');
            var enableStatus = await geoLocator.isLocationServiceEnabled();
            print('Enable Status: $enableStatus');
            if (!enableStatus) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return LocationErrorScreen(
                    error:
                        'Location service not enabled. Please enable location',
                  );
                }),
              );
            } else {
              NetworkResponse response =
                  await NetworkServices.shared.getAllShops(context: context);
              if (response.code == 1) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomeScreen();
                      },
                      settings: RouteSettings(name: 'HomeScreen'),
                    ),
                    (route) => false);

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return HomeScreen();
                //     },
                //     settings: RouteSettings(name: 'HomeScreen'),
                //   ),
                // );
              }
            }
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ErrorScreen(
                error: response.message,
              );
            }),
          );
        }
      }
    } on SocketException catch (_) {
      print('not connected');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ErrorScreen(
            error:
                'Internet service not available. Please connect to internet and try again',
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bgImg.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Container(
            height: 75.0 * _controller.value,
            width: 200.0 * _controller.value,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'images/logo1.png',
                  ),
                  fit: BoxFit.fill),
            ),
          ),
        ),
      ),
    );
  }
}
