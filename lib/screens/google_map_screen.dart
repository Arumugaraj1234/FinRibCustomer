import 'dart:async';
import 'package:finandrib/customized_widgets/address_tf.dart';
import 'package:finandrib/models/address.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  FocusNode _landMarkFc = FocusNode();
  FocusNode _streetFc = FocusNode();
  FocusNode _areaFc = FocusNode();
  FocusNode _postalFc = FocusNode();
  TextEditingController _landMarkTc = TextEditingController();
  TextEditingController _streetTc = TextEditingController();
  TextEditingController _areaTc = TextEditingController();
  TextEditingController _postalTc = TextEditingController();
  CameraPosition finalPosition;

  CameraPosition positionAtStopped;
  Completer<GoogleMapController> _mapController = Completer();

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    if (_initialPosition != null) {
      LatLng position = _initialPosition;

      Future.delayed(Duration(seconds: 1), () async {
        GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: 17.0,
            ),
          ),
        );
      });
    }
  }

  static LatLng _initialPosition = LatLng(0.0, 0.0);
  Completer<GoogleMapController> controller1;
  MapType _currentMapType = MapType.normal;
  List<Marker> allMarkers = [];

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Marker mark = Marker(
      markerId: MarkerId('myMarker'),
      draggable: false,
      position: LatLng(position.latitude, position.longitude),
    );
    Placemark placeA = placemark[0];
    String name = placeA.name == '' ? '' : placeA.name + ',';
    String subThroughFare =
        placeA.subThoroughfare == '' ? '' : placeA.subThoroughfare + ',';
    String throughFare =
        placeA.thoroughfare == '' ? '' : placeA.thoroughfare + ',';
    String subLocality =
        placeA.subLocality == '' ? '' : placeA.subLocality + ',';
    String locality = placeA.locality == '' ? '' : placeA.locality + ',';
    String subAdministrativeArea = placeA.subAdministrativeArea == ''
        ? ''
        : placeA.subAdministrativeArea + ',';
    String administrativeArea =
        placeA.administrativeArea == '' ? '' : placeA.administrativeArea;
    String postal = placeA.postalCode;

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);

      if (_initialPosition != null) {
        LatLng position = _initialPosition;

        Future.delayed(Duration(seconds: 1), () async {
          GoogleMapController controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: position,
                zoom: 17.0,
              ),
            ),
          );
        });
      }

      _streetTc.text = name + subThroughFare + throughFare;
      _areaTc.text =
          subLocality + locality + subAdministrativeArea + administrativeArea;
      _postalTc.text = postal;
      allMarkers.add(mark);
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _landMarkFc.addListener(_onLandMarkFocusChange);
    _streetFc.addListener(_onStreetFocusChange);
    _areaFc.addListener(_onAreaFocusChange);
    _postalFc.addListener(_onPinCodeFocusChange);
  }

  void _onLandMarkFocusChange() {
    debugPrint("LandMarkFocus: " + _landMarkFc.hasFocus.toString());
  }

  void _onStreetFocusChange() {
    debugPrint("StreetFocus: " + _streetFc.hasFocus.toString());
  }

  void _onAreaFocusChange() {
    debugPrint("AreaFocus: " + _areaFc.hasFocus.toString());
  }

  void _onPinCodeFocusChange() {
    debugPrint("PinCodeFocus: " + _postalFc.hasFocus.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _landMarkFc.dispose();
    _streetFc.dispose();
    _areaFc.dispose();
    _postalFc.dispose();
    _landMarkTc.dispose();
    _streetTc.dispose();
    _areaTc.dispose();
    _postalTc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Select Location',
          style: kTextStyleAppBarTitle,
        ),
      ),
      body: SingleChildScrollView(
        physics: (_landMarkFc.hasFocus ||
                _streetFc.hasFocus ||
                _areaFc.hasFocus ||
                _postalFc.hasFocus)
            ? null
            : NeverScrollableScrollPhysics(),
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height - 80,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _initialPosition,
                                zoom: 14.4746,
                              ),
                              mapType: _currentMapType,
                              onMapCreated: _onMapCreated,
                              myLocationEnabled: true,
                              compassEnabled: true,
                              myLocationButtonEnabled: true,
                              onCameraIdle: () async {
                                List<Placemark> place = await Geolocator()
                                    .placemarkFromCoordinates(
                                        finalPosition.target.latitude,
                                        finalPosition.target.longitude);
                                _initialPosition = LatLng(
                                    finalPosition.target.latitude,
                                    finalPosition.target.longitude);
                                Placemark placeA = place[0];
                                String name =
                                    placeA.name == '' ? '' : placeA.name + ',';
                                String subThroughFare =
                                    placeA.subThoroughfare == ''
                                        ? ''
                                        : placeA.subThoroughfare + ',';
                                String throughFare = placeA.thoroughfare == ''
                                    ? ''
                                    : placeA.thoroughfare + ',';
                                String subLocality = placeA.subLocality == ''
                                    ? ''
                                    : placeA.subLocality + ',';
                                String locality = placeA.locality == ''
                                    ? ''
                                    : placeA.locality + ',';
                                String subAdministrativeArea =
                                    placeA.subAdministrativeArea == ''
                                        ? ''
                                        : placeA.subAdministrativeArea + ',';
                                String administrativeArea =
                                    placeA.administrativeArea == ''
                                        ? ''
                                        : placeA.administrativeArea;
                                String postal = placeA.postalCode;
                                print(placeA.toJson());
                                setState(() {
                                  _streetTc.text =
                                      name + subThroughFare + throughFare;
                                  _areaTc.text = subLocality +
                                      locality +
                                      subAdministrativeArea +
                                      administrativeArea;
                                  _postalTc.text = postal;
                                });
                              },
                              onCameraMove: (CameraPosition position) async {
                                finalPosition = position;
                              }),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 80.0,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Icon(
                                      FontAwesomeIcons.mapPin,
                                      size: 40.0,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                  ),
                                  Expanded(child: Container())
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 190.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AddressTF(
                            controller: _landMarkTc,
                            focusNode: _landMarkFc,
                            labelText: 'Land Mark',
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.words,
                            onSubmitted: (newValue) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            onChanged: (newValue) {},
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          AddressTF(
                            controller: _streetTc,
                            focusNode: _streetFc,
                            labelText: 'House No & Street',
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.words,
                            onSubmitted: (newValue) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            onChanged: (newValue) {},
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: AddressTF(
                                  controller: _areaTc,
                                  focusNode: _areaFc,
                                  labelText: 'Area',
                                  inputAction: TextInputAction.done,
                                  inputType: TextInputType.text,
                                  capitalization: TextCapitalization.words,
                                  onSubmitted: (newValue) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  onChanged: (newValue) {},
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Container(
                                width: 100.0,
                                child: AddressTF(
                                  controller: _postalTc,
                                  focusNode: _postalFc,
                                  labelText: 'Postal',
                                  inputAction: TextInputAction.done,
                                  inputType: TextInputType.text,
                                  capitalization: TextCapitalization.words,
                                  onSubmitted: (newValue) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  onChanged: (newValue) {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
              Container(
                color: Colors.deepOrange,
                width: double.infinity,
                height: 40.0,
                child: FlatButton(
                    onPressed: () {
                      if (_initialPosition.longitude != 0.0 &&
                          _initialPosition.latitude != 0.0) {
                        String landMark = _landMarkTc.text != ''
                            ? (_landMarkTc.text + ', ')
                            : '';
                        String street = _streetTc.text;
                        String area = _areaTc.text;
                        String postal = _postalTc.text;
                        String fullAddress =
                            landMark + street + area + ' - ' + postal;

                        Address address = Address(
                            id: 0,
                            fullAddress: fullAddress,
                            latitude: _initialPosition.latitude,
                            longitude: _initialPosition.longitude,
                            postal: postal);
                        Navigator.pop(context, address);
                      }
                    },
                    child: Text(
                      'SAVE ADDRESS',
                      style: kTextStyleCalibriBold.copyWith(
                          color: Colors.white, fontSize: 16),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
