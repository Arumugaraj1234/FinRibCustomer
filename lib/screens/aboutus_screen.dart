import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String aboutUs =
      " We are a young startup with a bold dream, a dream to transform people's "
      "experience of buying meat and to reacquaint them with its real flavors.Buying meat in"
      " wet markets or from butchers is an unpleasant experience characterized by a perpetual "
      "stench, buzzing flies and the revolting sight of meat hung upside down. This meat is"
      "stale, unhygienic, low on taste, and unfit for human consumption according to World Health"
      "Oraganization (WHO) guidelines which state that meat kept at temperatures between 5 to 6 "
      "degrees Celsius can slowly become poisonous. Our  direct partnership with local farming and"
      " fishing communities and strong backward linkages ensure that the Fin & Rib meat travels a "
      "very short distance to reach you, guaranteeing absolute freshness. We have integrated our"
      " partners into a just ecosystem of fair prices and timely payments, encouraging them to practice"
      "ethical farming that brings you chemical free and preservative free produce.";

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          // leading: IconButton(
          //     icon: Icon(
          //       Icons.arrow_back,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     }),
          title: Text(
            'About us',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
              child: Center(
                child: Text(
                  'Fin & Rib',
                  style: TextStyle(
                      fontFamily: 'Calibri',
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                aboutUs,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontFamily: 'Calibri',
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      );
    });
  }
}
