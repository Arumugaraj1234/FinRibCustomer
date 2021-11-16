import 'dart:io';

import 'package:finandrib/models/init_settings.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info/package_info.dart';

import 'home_screen.dart';
import 'initial_instruction_screen.dart';
import 'location_error_screen.dart';

class ErrorScreen extends StatefulWidget {
  final String error;
  ErrorScreen({this.error});
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen();
                    },
                    settings: RouteSettings(name: 'HomeScreen'),
                  ),
                );
              }
            }
          }
        } else {}
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.error,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      _getInitSettings();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
