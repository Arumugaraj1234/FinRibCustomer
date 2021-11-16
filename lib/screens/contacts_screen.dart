import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
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
              'Support',
              style: kTextStyleAppBarTitle,
            ),
          ),
          body: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Contact Us",
                        style: TextStyle(
                            fontFamily: 'Calibri',
                            fontSize: 16,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey.shade200,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.email,
                    ),
                    title: Text(
                      'info@finandrib.com',
                      style: TextStyle(
                          fontFamily: 'Calibri',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey.shade200,
                  ),
                  Container(
                    height: 40.0,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      leading: Icon(
                        Icons.phone,
                      ),
                      title: Text(
                        '044-26562222',
                        style: TextStyle(
                            fontFamily: 'Calibri',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 72.0, bottom: 10.0),
                    child: Text(
                      '+91 9884898002',
                      style: TextStyle(
                          fontFamily: 'Calibri',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey.shade200,
                  ),
                  Container(
                    height: 40.0,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      leading: Icon(
                        Icons.location_on,
                      ),
                      title: Text(
                        '6th Block, Ground Floor, 6/23',
                        style: TextStyle(
                          fontFamily: 'Calibri',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 72.0),
                    child: Text(
                      'Shans Enclave, Valayapathi Street,',
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 72.0),
                    child: Text(
                      'Mogappair East, Chennai',
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 72.0, bottom: 10.0),
                    child: Text(
                      'Tamil Nadu, 600037',
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
