import 'dart:async';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/models/order_status.dart';
import 'package:finandrib/models/rider.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OrderTrackScreen extends StatefulWidget {
  final Order order;
  final int index;
  final String googleKey;
  OrderTrackScreen({this.order, this.index, this.googleKey});
  @override
  _OrderTrackScreenState createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen> {
  Order _order;
  Completer<GoogleMapController> _mapController = Completer();
  int _riderId = 0;
  Timer _timerToGetRiderId;
  Timer _timerToGetRiderLocation;
  Timer _timerToTrackOrder;
  Rider _riderData;
  int flag = 0;
  bool _isOrderStatusViewVisible = false;
  List<OrderStatus> _totalStatus = [
    OrderStatus(name: 'Received', time: '', status: TickStatus.unselected),
    OrderStatus(name: 'Prepared', time: '', status: TickStatus.unselected),
    OrderStatus(
        name: 'Ride Allocated', time: '', status: TickStatus.unselected),
    OrderStatus(
        name: 'Out For Delivery', time: '', status: TickStatus.unselected),
    OrderStatus(name: 'Delivered', time: '', status: TickStatus.unselected),
    OrderStatus(name: 'Completed', time: '', status: TickStatus.unselected),
    OrderStatus(name: 'Cancelled', time: '', status: TickStatus.unselected),
  ];
  String _googleKey = '';

  @override
  void initState() {
    super.initState();

    setSourceAndDestinationIcons();
    setState(() {
      _googleKey = widget.googleKey;
      _order = widget.order;
      _riderId = widget.order.riderId;
    });

    if (_riderId == 0) {
      _getOrdersHistoryForFirstTime();
      _startTimerToGetRiderId();
    } else {
      _getRiderDataForFirstTime();
      _startTimerToGetRiderDetails();
    }
    _getOrderStatusForFirstTime();
    _startTimerToTrackOrder();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timerToGetRiderId != null) {
      _timerToGetRiderId.cancel();
    }

    if (_timerToGetRiderLocation != null) {
      _timerToGetRiderLocation.cancel();
    }

    _timerToTrackOrder.cancel();
  }

  void _startTimerToGetRiderId() {
    const tenSec = const Duration(seconds: 10);
    _timerToGetRiderId = new Timer.periodic(
      tenSec,
      (Timer timer) {
        if (_riderId == 0) {
          _getOrdersHistoryInLoop();
        } else {
          _startTimerToGetRiderDetails();
          print('History Timer got cancel');
          setState(() {
            timer.cancel();
          });
        }
      },
    );
  }

  void _getOrdersHistoryInLoop() async {
    print("getting history");
    NetworkResponse response =
        await NetworkServices.shared.getOrdersHistory(context: context);
    if (response.code == 1) {
      List<Order> orders = response.data;
      for (Order o in orders) {
        if (o.orderId == _order.orderId) {
          if (!mounted) return;
          setState(() {
            _riderId = o.riderId;
          });
        }
      }
    }
  }

  void _getOrdersHistoryForFirstTime() async {
    print("One");
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    NetworkResponse response =
        await NetworkServices.shared.getOrdersHistory(context: context);
    await dialog.hide();
    if (response.code == 1) {
      List<Order> orders = response.data;
      for (Order o in orders) {
        if (o.orderId == _order.orderId) {
          if (!mounted) return;
          setState(() {
            _riderId = o.riderId;
          });
        }
      }
    }
  }

  void _startTimerToGetRiderDetails() {
    const tenSec = const Duration(seconds: 10);
    _timerToGetRiderLocation = new Timer.periodic(
      tenSec,
      (Timer timer) {
        _getRiderDataInLoop();
      },
    );
  }

  void _getRiderDataForFirstTime() async {
    print("Two");
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    NetworkResponse response = await NetworkServices.shared
        .getRiderLocation(riderId: _riderId, context: context);
    await dialog.hide();
    if (response.code == 1) {
      if (!mounted) return;
      setState(() {
        _riderData = response.data;
      });
      if (_order.deliveryLatitude > 0 && _order.deliveryLongitude > 0) {
        LatLng temp;

        LatLng sourceLocation =
            LatLng(_riderData.latitude, _riderData.longitude);
        LatLng destLocation =
            LatLng(_order.deliveryLatitude, _order.deliveryLongitude);

        if (sourceLocation.latitude > destLocation.latitude) {
          temp = sourceLocation;
          sourceLocation = destLocation;
          destLocation = temp;
        }

        LatLngBounds bound =
            LatLngBounds(southwest: sourceLocation, northeast: destLocation);

        setMapPins(
            driverLocation: sourceLocation, deliveryLocation: destLocation);
        setPolylines(
            driverLocation: sourceLocation, deliveryLocation: destLocation);

        CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
        GoogleMapController controller = await _mapController.future;
        controller.animateCamera(u2).then((void v) {
          check(u2, controller);
        });
      } else {
        LatLng sourceLocation =
            LatLng(_riderData.latitude, _riderData.longitude);
        setState(() {
          _markers.clear();
          // source pin
          _markers.add(Marker(
              markerId: MarkerId('sourcePin'),
              position:
                  LatLng(sourceLocation.latitude, sourceLocation.longitude),
              icon: destinationIcon));
        });

        var newPosition = CameraPosition(
            target: LatLng(_riderData.latitude, _riderData.longitude),
            zoom: 16);

        CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
        //CameraUpdate zoom = CameraUpdate.zoomTo(16);
        GoogleMapController controller = await _mapController.future;
        controller.moveCamera(update);
      }
    }
  }

  void _getRiderDataInLoop() async {
    print("getting rider details");
    NetworkResponse response = await NetworkServices.shared
        .getRiderLocation(riderId: _riderId, context: context);
    if (response.code == 1) {
      if (!mounted) return;
      setState(() {
        _riderData = response.data;
      });
      if (_order.deliveryLatitude > 0 && _order.deliveryLongitude > 0) {
        LatLng temp;

        LatLng sourceLocation =
            LatLng(_riderData.latitude, _riderData.longitude);
        LatLng destLocation =
            LatLng(_order.deliveryLatitude, _order.deliveryLongitude);

        if (sourceLocation.latitude > destLocation.latitude) {
          temp = sourceLocation;
          sourceLocation = destLocation;
          destLocation = temp;
        }

        LatLngBounds bound =
            LatLngBounds(southwest: sourceLocation, northeast: destLocation);

        setMapPins(
            driverLocation: sourceLocation, deliveryLocation: destLocation);
        setPolylines(
            driverLocation: sourceLocation, deliveryLocation: destLocation);

        CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
        GoogleMapController controller = await _mapController.future;
        controller.animateCamera(u2).then((void v) {
          check(u2, controller);
        });
      } else {
        LatLng sourceLocation =
            LatLng(_riderData.latitude, _riderData.longitude);
        setState(() {
          _markers.clear();
          // source pin
          _markers.add(Marker(
              markerId: MarkerId('sourcePin'),
              position:
                  LatLng(sourceLocation.latitude, sourceLocation.longitude),
              icon: destinationIcon));
        });

        var newPosition = CameraPosition(
            target: LatLng(_riderData.latitude, _riderData.longitude),
            zoom: 16);

        CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
        //CameraUpdate zoom = CameraUpdate.zoomTo(16);
        GoogleMapController controller = await _mapController.future;
        controller.moveCamera(update);
      }
    }
  }

  void _startTimerToTrackOrder() {
    const tenSec = const Duration(seconds: 10);
    _timerToTrackOrder = new Timer.periodic(
      tenSec,
      (Timer timer) {
        if (this.mounted) {
          _getOrderStatusInLoop();
        }
      },
    );
  }

  void _getOrderStatusForFirstTime() async {
    print("Three");
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    NetworkResponse response = await NetworkServices.shared
        .trackOrder(orderId: _order.orderId, context: context);
    await dialog.hide();
    if (response.code == 1) {
      //if (!mounted) return;
      if (this.mounted) {
        setState(() {
          _totalStatus = response.data;
        });
      }
    }
  }

  void _getOrderStatusInLoop() async {
    NetworkResponse response = await NetworkServices.shared
        .trackOrder(orderId: _order.orderId, context: context);
    if (response.code == 1) {
      //if (!mounted) return;
      if (this.mounted) {
        setState(() {
          _totalStatus = response.data;
        });
      }
    }
  }

  //static LatLng _initialPosition = LatLng(0.0, 0.0);
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
// for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/bike.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/rider_location.png');
  }

  // BitmapDescriptor mapMarker;
  // void setCustomMarker() async {
  //   mapMarker = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(), 'images/rider_location.png');
  // }

  //13.078958103131663, 80.18744011534235
  //13.084057904456637, 80.19542236901947

  void setMapPins({LatLng driverLocation, LatLng deliveryLocation}) {
    setState(() {
      _markers.clear();
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(driverLocation.latitude, driverLocation.longitude),
          icon: destinationIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position:
              LatLng(deliveryLocation.latitude, deliveryLocation.longitude),
          icon: sourceIcon));
    });
  }

  setPolylines({LatLng driverLocation, LatLng deliveryLocation}) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        _googleKey,
        PointLatLng(driverLocation.latitude, driverLocation.longitude),
        PointLatLng(deliveryLocation.latitude, deliveryLocation.longitude));
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: Colors.deepOrange,
          points: polylineCoordinates,
          width: 3);
      _polylines.add(polyline);
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);

    if (_riderData != null) {
      LatLng temp;

      LatLng sourceLocation = LatLng(_riderData.latitude, _riderData.longitude);
      LatLng destLocation =
          LatLng(_order.deliveryLatitude, _order.deliveryLongitude);

      if (sourceLocation.latitude > destLocation.latitude) {
        temp = sourceLocation;
        sourceLocation = destLocation;
        destLocation = temp;
      }

      LatLngBounds bound =
          LatLngBounds(southwest: sourceLocation, northeast: destLocation);

      setMapPins(
          driverLocation: sourceLocation, deliveryLocation: destLocation);
      setPolylines(
          driverLocation: sourceLocation, deliveryLocation: destLocation);

      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      controller.animateCamera(u2).then((void v) {
        check(u2, controller);
      });
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    //mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());

    // if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
    //   check(u, c);
    // else {
    //   await setPolylines();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORDER #${_order.orderId}',
              style: kTextStyleCalibriBold.copyWith(fontSize: 16),
            ),
            Text(
              '${_order.orderDate} | ${_order.products.length} item, $kMoneySymbol${_order.totalAmount.toStringAsFixed(2)}',
              style: kTextStyleCalibri300.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: 35,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Center(
                        child: Text(
                      _isOrderStatusViewVisible
                          ? 'LIVE LOCATION'
                          : 'CHECK STATUS',
                      textAlign: TextAlign.center,
                      style: kTextStyleCalibriBold.copyWith(fontSize: 12),
                    ))),
              ),
            ),
            onTap: () {
              setState(() {
                _isOrderStatusViewVisible = !_isOrderStatusViewVisible;
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(13.07890, 80.18739),
                              zoom: 14.4746,
                            ),
                            markers: _markers,
                            polylines: _polylines,
                            mapType: _currentMapType,
                            onMapCreated: _onMapCreated,
                            myLocationEnabled: true,
                            compassEnabled: true,
                            myLocationButtonEnabled: true,
                            onCameraIdle: () {},
                            onCameraMove: (CameraPosition position) async {
                              //finalPosition = position;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _riderData != null ? true : false,
                    child: Container(
                      height: 100,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'images/driver.png'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                                style: kTextStyleCalibri300
                                                    .copyWith(
                                                        fontSize: 15,
                                                        color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${_riderData != null ? _riderData.name : ''}',
                                                    style: kTextStyleCalibriBold
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                          ' is on the way to deliver your order')
                                                ]),
                                          ),
                                        ),
                                        IconButton(
                                            icon: Icon(
                                              Icons.phone,
                                              color: Colors.deepOrange,
                                              size: 30,
                                            ),
                                            onPressed: () => launch(
                                                "tel://${_riderData != null ? _riderData.phone : ''}"))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  /*Container(
                    height: 40,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        'ORDER STATUS',
                        style: kTextStyleCalibriBold.copyWith(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ,
                  ),*/
                ],
              ),
            ),
          ),
          Visibility(
            visible: _isOrderStatusViewVisible,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                child: ListView(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[0].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[0].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[0].time == '' ? false : true,
                              child: Text(
                                _totalStatus[0].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 40,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[1].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[1].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[1].time == '' ? false : true,
                              child: Text(
                                _totalStatus[1].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[2].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[2].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[2].time == '' ? false : true,
                              child: Text(
                                _totalStatus[2].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[3].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[3].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[3].time == '' ? false : true,
                              child: Text(
                                _totalStatus[3].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[4].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[4].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[4].time == '' ? false : true,
                              child: Text(
                                _totalStatus[4].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[5].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[5].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[5].time == '' ? false : true,
                              child: Text(
                                _totalStatus[5].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _totalStatus[6].status == TickStatus.selected
                              ? Colors.deepOrange
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalStatus[6].name,
                              style:
                                  kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            Visibility(
                              visible:
                                  _totalStatus[6].time == '' ? false : true,
                              child: Text(
                                _totalStatus[6].time,
                                style:
                                    kTextStyleCalibri300.copyWith(fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.my_location,
                          size: 25,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            _order.deliveryAddress,
                            style: kTextStyleCalibri300.copyWith(fontSize: 16),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
