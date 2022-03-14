import 'package:finandrib/models/init_settings.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

import 'home_screen.dart';

class InitialInstructionScreen extends StatefulWidget {
  final InitSettings settings;

  InitialInstructionScreen({this.settings});
  @override
  _InitialInstructionScreenState createState() =>
      _InitialInstructionScreenState();
}

class _InitialInstructionScreenState extends State<InitialInstructionScreen> {
  InitSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings;
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
                  settings.message,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: settings.status == 2 ? false : true,
                      child: RaisedButton(
                        onPressed: () async {
                          NetworkResponse response = await NetworkServices
                              .shared
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
                        },
                        child: Text(
                          'Later',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    // Visibility(
                    //   visible: (settings.status == 2 || settings.status == 1)
                    //       ? true
                    //       : false,
                    //   child: SizedBox(
                    //     width: 50,
                    //   ),
                    // ),
                    RaisedButton(
                      onPressed: () {
                        LaunchReview.launch(
                          androidAppId: "com.clt.fin_and_rib",
                          iOSAppId: "1561107675",
                        );
                      },
                      child: Text(
                        'Update Now',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.orange,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
