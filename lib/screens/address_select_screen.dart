import 'package:finandrib/models/address.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:finandrib/screens/google_map_screen.dart';
import 'package:finandrib/screens/address_entry_screen.dart';
import 'package:finandrib/screens/delivery_type_screen.dart';
import 'delivery_type_one_screen.dart';
import 'dart:io' show Platform;

class AddressSelectScreen extends StatefulWidget {
  final int shopId;
  AddressSelectScreen({this.shopId});
  @override
  _AddressSelectScreenState createState() => _AddressSelectScreenState();
}

class _AddressSelectScreenState extends State<AddressSelectScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _getAllAddress() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    await NetworkServices.shared.getAllAddress(widget.shopId, context);
    await dialog.hide();
  }

  @override
  void initState() {
    super.initState();
    _getAllAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (cxt, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          leading: IconButton(
              icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('HomeScreen'),
                );
              }),
          title: Text(
            'Select Delivery Address',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: dataServices.allAddress.length + 1,
                    itemBuilder: (context, index) {
                      if (index == (dataServices.allAddress.length)) {
                        return Container(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlineButton(
                                  onPressed: () async {
                                    var geoLocator = Geolocator();
                                    var status = await geoLocator
                                        .checkGeolocationPermissionStatus();
                                    print('Location Status: $status');
                                    var enableStatus = await geoLocator
                                        .isLocationServiceEnabled();
                                    print('Enable Status: $enableStatus');

                                    if (!enableStatus) {
                                      _showSnackBar(
                                          'Location service not enabled. Please enable location');
                                    } else {
                                      Address address = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return GoogleMapScreen();
                                          },
                                        ),
                                      );
                                      if (address != null) {
                                        NetworkResponse response =
                                            await NetworkServices.shared
                                                .addOrRemoveAddress(
                                                    address: address,
                                                    type: 1,
                                                    shopId: widget.shopId,
                                                    context: context);
                                        if (response.code != 1) {
                                          //_showSnackBar(response.message);
                                          NetworkServices.shared
                                              .showAlertDialog(
                                                  context,
                                                  'Failed',
                                                  response.message, () async {
                                            Navigator.pop(context);
                                          });
                                        } else {
                                          _showSnackBar(response.message);
                                          // Fluttertoast.showToast(
                                          //     msg: response.responseMessage,
                                          //     backgroundColor: Colors.green,
                                          //     textColor: Colors.white);
                                        }
                                      } else {
                                        _showSnackBar('Address not selected');
                                        // Fluttertoast.showToast(
                                        //     msg: 'Address not selected',
                                        //     backgroundColor: Colors.red,
                                        //     textColor: Colors.white);
                                      }
                                    }
                                  },
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange, width: 2),
                                  child: Text(
                                    'PIN LOCATION',
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 16),
                                  ),
                                ),
                                OutlineButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return AddressEntryScreen();
                                      }),
                                    );
                                  },
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange, width: 2),
                                  child: Text(
                                    'MANUAL ENTRY',
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        Address address = dataServices.allAddress[index];
                        return AddressWidget(
                          isSelected: dataServices.selectedAddressIndex == index
                              ? true
                              : false,
                          address: address,
                          onSelected: () {
                            dataServices.setSelectedAddressIndex(index);
                          },
                          onRemove: () async {
                            ProgressDialog dialog = new ProgressDialog(context);
                            dialog.style(message: 'Please wait...');
                            await dialog.show();
                            NetworkResponse response =
                                await NetworkServices.shared.addOrRemoveAddress(
                                    address: address,
                                    type: 2,
                                    shopId: widget.shopId,
                                    context: context);
                            await dialog.hide();
                            if (response.code != 1) {
                              _showSnackBar(response.message);
                            }
                          },
                        );
                      }
                    }),
              ),
              Container(
                height: 40.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Total',
                                style: kTextStyleCalibri600.copyWith(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '$kMoneySymbol ${dataServices.selectedProductsTotalPrice.toStringAsFixed(2)}',
                                style: kTextStyleCalibri600.copyWith(
                                    fontSize: 16.0, color: Colors.deepOrange),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                    Expanded(
                      child: Container(
                        color: Colors.deepOrange,
                        height: double.infinity,
                        child: FlatButton(
                          onPressed: () async {
                            if (dataServices.selectedAddress != null) {
                              ProgressDialog dialog =
                                  new ProgressDialog(context);
                              await dialog.show();
                              NetworkResponse response = await NetworkServices
                                  .shared
                                  .getDeliveryCharges(
                                      hotelId: dataServices.selectedShop.id,
                                      postal:
                                          dataServices.selectedAddress.postal,
                                      context: context);
                              await dialog.hide();
                              if (response.code == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return DeliveryTypeOneScreen(
                                      selectedShopId:
                                          dataServices.selectedShop.id,
                                    );
                                  }),
                                );
                              } else {
                                _showSnackBar(response.message);
                              }
                            } else {
                              _showSnackBar(
                                  'Please select address before proceed');
                            }
                          },
                          child: Text(
                            'PROCEED',
                            style: kTextStyleCalibriBold.copyWith(
                                fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class AddressWidget extends StatelessWidget {
  final bool isSelected;
  final Address address;
  final Function onSelected;
  final Function onRemove;

  AddressWidget(
      {this.isSelected, this.address, this.onSelected, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30.0,
                    child: Center(
                      child: IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20.0,
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                          onPressed: onSelected),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: onSelected,
                      child: Text(address.fullAddress,
                          style: kTextStyleCalibri300.copyWith(fontSize: 16)),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20.0,
                      ),
                      onPressed: onRemove)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
