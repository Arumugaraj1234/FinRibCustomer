import 'package:finandrib/customized_widgets/custom_tf_one.dart';
import 'package:finandrib/models/address.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class AddressEntryScreen extends StatefulWidget {
  @override
  _AddressEntryScreenState createState() => _AddressEntryScreenState();
}

class _AddressEntryScreenState extends State<AddressEntryScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  TextEditingController _flatNoTC = new TextEditingController();
  TextEditingController _addressOneTC = new TextEditingController();
  TextEditingController _addressTwoTC = new TextEditingController();
  TextEditingController _cityTC = new TextEditingController();
  TextEditingController _stateTC = new TextEditingController();
  TextEditingController _pinCodeTC = new TextEditingController();
  TextEditingController _landMarkTC = new TextEditingController();
  FocusNode _flatNoFN = new FocusNode();
  FocusNode _addressOneFN = new FocusNode();
  FocusNode _addressTwoFN = new FocusNode();
  FocusNode _cityFN = new FocusNode();
  FocusNode _stateFN = new FocusNode();
  FocusNode _pinCodeFN = new FocusNode();
  FocusNode _landMarkFN = new FocusNode();
  bool _isFlatNoValid;
  bool _isAddressOneValid;
  bool _isCityValid;
  bool _isStateValid;
  bool _isPinCodeValid;
  String _errorMsg = '';

  @override
  void dispose() {
    super.dispose();
    _flatNoTC.dispose();
    _addressOneTC.dispose();
    _addressTwoTC.dispose();
    _cityTC.dispose();
    _stateTC.dispose();
    _pinCodeTC.dispose();
    _landMarkTC.dispose();
    _flatNoFN.dispose();
    _addressOneFN.dispose();
    _addressTwoFN.dispose();
    _cityFN.dispose();
    _stateFN.dispose();
    _pinCodeFN.dispose();
    _landMarkFN.dispose();
  }

  bool _valuateForValidAddress() {
    bool isFlatNoValid;
    bool isAddressOneValid;
    bool isCityValid;
    bool isStateValid;
    bool isPinCodeValid;
    _errorMsg = '';

    String pinCode = _pinCodeTC.text.replaceAll(RegExp(' '), '');
    if (pinCode.length == 6) {
      isPinCodeValid = true;
    } else {
      isPinCodeValid = false;
      _errorMsg = 'Invalid pincode';
    }

    if (_stateTC.text != '') {
      isStateValid = true;
    } else {
      isStateValid = false;
      _errorMsg = 'Please provide state details';
    }

    if (_cityTC.text != '') {
      isCityValid = true;
    } else {
      isCityValid = false;
      _errorMsg = 'Please provide city details';
    }

    if (_addressOneTC.text != '') {
      isAddressOneValid = true;
    } else {
      isAddressOneValid = false;
      _errorMsg = 'Please provide Address One details';
    }

    if (_flatNoTC.text != '') {
      isFlatNoValid = true;
    } else {
      isFlatNoValid = false;
      _errorMsg = 'Please provide flat number details';
    }

    setState(() {
      _isFlatNoValid = isFlatNoValid;
      _isAddressOneValid = isAddressOneValid;
      _isCityValid = isCityValid;
      _isStateValid = isStateValid;
      _isPinCodeValid = isPinCodeValid;
    });

    bool isValid = false;
    if (isFlatNoValid &&
        isAddressOneValid &&
        isCityValid &&
        isStateValid &&
        isPinCodeValid) {
      isValid = true;
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Enter Delivery Address',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: Container(
          child: Container(
            constraints: BoxConstraints.expand(),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 110.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20.0,
                              ),
                              CustomTFOne(
                                controller: _flatNoTC,
                                focusNode: _flatNoFN,
                                labelText: 'Flat No',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_addressOneFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _addressOneTC,
                                focusNode: _addressOneFN,
                                labelText: 'Address1',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_addressTwoFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _addressTwoTC,
                                focusNode: _addressTwoFN,
                                labelText: 'Address2',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(_cityFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _cityTC,
                                focusNode: _cityFN,
                                labelText: 'City',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(_stateFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _stateTC,
                                focusNode: _stateFN,
                                labelText: 'State',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_pinCodeFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _pinCodeTC,
                                focusNode: _pinCodeFN,
                                labelText: 'Pincode',
                                inputType: TextInputType.number,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_landMarkFN);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CustomTFOne(
                                controller: _landMarkTC,
                                focusNode: _landMarkFN,
                                labelText: 'Landmark',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.done,
                                capitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: double.infinity,
                    color: Colors.deepOrange,
                    child: MaterialButton(
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(
                          new FocusNode(),
                        );
                        if (_valuateForValidAddress()) {
                          ProgressDialog dialog = new ProgressDialog(context);
                          dialog.style(message: 'Saving...');
                          await dialog.show();
                          String landMark = _landMarkTC.text == ''
                              ? ''
                              : _landMarkTC.text + ', ';
                          String addressTwo = _addressTwoTC.text == ''
                              ? ''
                              : _addressTwoTC.text + ',';
                          String pincode = _pinCodeTC.text.replaceAll(' ', '');
                          String fullAddress = _flatNoTC.text +
                              ', ' +
                              landMark +
                              _addressOneTC.text +
                              ', ' +
                              addressTwo +
                              _cityTC.text +
                              ', ' +
                              _stateTC.text +
                              ', ' +
                              pincode;

                          Address addressSel = Address(
                              id: 0,
                              fullAddress: fullAddress,
                              latitude: 0.0,
                              longitude: 0.0,
                              postal: pincode);
                          NetworkResponse response =
                              await NetworkServices.shared.addOrRemoveAddress(
                                  address: addressSel,
                                  type: 1,
                                  shopId: dataServices.selectedShop.id,
                                  context: context);
                          await dialog.hide();
                          if (response.code != 1) {
                            NetworkServices.shared.showAlertDialog(
                                context, 'Failed', response.message, () async {
                              Navigator.pop(context);
                            });
                            //_showSnackBar(response.message);
                          } else {
                            //dataServices.addAddressToList(addressSel);
                            Navigator.pop(context);
                          }
                        } else {
                          _showSnackBar(_errorMsg);
                          // Fluttertoast.showToast(
                          //     msg: _errorMsg,
                          //     backgroundColor: Colors.red,
                          //     textColor: Colors.white,
                          //     gravity: ToastGravity.BOTTOM,
                          //     toastLength: Toast.LENGTH_LONG);
                        }
                      },
                      child: Text(
                        'SAVE',
                        style: kTextStyleCalibriBold.copyWith(
                            fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
