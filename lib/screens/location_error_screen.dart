import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'home_screen.dart';

class LocationErrorScreen extends StatefulWidget {
  final String error;
  LocationErrorScreen({this.error});
  @override
  _LocationErrorScreenState createState() => _LocationErrorScreenState();
}

class _LocationErrorScreenState extends State<LocationErrorScreen> {
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
                    onPressed: () async {
                      var geoLocator = Geolocator();
                      var status =
                          await geoLocator.checkGeolocationPermissionStatus();
                      print('Location Status: $status');
                      var enableStatus =
                          await geoLocator.isLocationServiceEnabled();
                      print('Enable Status: $enableStatus');
                      if (!enableStatus) {
                      } else {
                        NetworkResponse response = await NetworkServices.shared
                            .getAllShops(context: context);
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
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
