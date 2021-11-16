import 'package:date_format/date_format.dart';
import 'package:finandrib/models/address.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/screens/order_details_screen.dart';
import 'package:finandrib/screens/order_track_screen.dart';
import 'package:finandrib/screens/rate_order_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex = 0;
  String _errorMessage = '';
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _getOrdersHistory() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    NetworkResponse response =
        await NetworkServices.shared.getOrdersHistory(context: context);
    await dialog.hide();

    if (response.code == 1) {
      setState(() {
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }
  }

  void _cancelOrder(int orderId, DataServices ds) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Cancelling...');
    await dialog.show();
    NetworkResponse response = await NetworkServices.shared.cancelCard(orderId);
    await dialog.hide();
    if (response.code == 1) {
      if (ds.activeOrders.length > 0) {
        if (ds.activeOrders[0].orderId == orderId) {
          ds.removeOrderFromActiveOrder(orderId: orderId);
        }
      }
      _getOrdersHistory();
      _showSnackBar(response.message);
    } else {
      _showSnackBar(response.message);
    }
  }

  @override
  void initState() {
    super.initState();
    print('History Init State');
    _controller = TabController(length: 3, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });
    _getOrdersHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'My Orders',
            style: kTextStyleAppBarTitle,
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            isScrollable: false,
            unselectedLabelColor: Colors.black,
            labelStyle: kTextStyleCalibri600.copyWith(fontSize: 16),
            tabs: [
              Tab(
                text: "LIVE",
              ),
              Tab(
                text: "COMPLETED",
              ),
              Tab(
                text: "CANCELLED",
              )
            ],
            onTap: (index) {},
            controller: _controller,
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: (_errorMessage != '')
                  ? ErrorText(error: _errorMessage)
                  : dataServices.liveOrders.length == 0
                      ? ErrorText(error: 'No live orders available to show')
                      : ListView.builder(
                          itemCount: dataServices.liveOrders.length,
                          itemBuilder: (context, index) {
                            Order order = dataServices.liveOrders[index];
                            return LiveOrderCard(
                              order: order,
                              onCancelTapped: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                        onWillPop: () {},
                                        child: new AlertDialog(
                                          title: new Text('Cancelling order!'),
                                          content: new Text(
                                              'Are you sure you want cancel the order?'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                _cancelOrder(order.orderId,
                                                    dataServices);
                                              },
                                              child: new Text('Yes'),
                                            ),
                                            new FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: new Text('No'),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              onInfoTapped: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(builder: (context) {
                                    return OrderDetailsScreen(
                                      order: order,
                                      index: index,
                                    );
                                  }),
                                );
                              },
                              onTrackTapped: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(builder: (context) {
                                    return OrderTrackScreen(
                                      order: order,
                                    );
                                  }),
                                );
                              },
                            );
                          }),
            ),
            Container(
              child: (_errorMessage != '')
                  ? ErrorText(error: _errorMessage)
                  : dataServices.completedOrders.length == 0
                      ? ErrorText(
                          error: 'No completed orders available to show')
                      : ListView.builder(
                          itemCount: dataServices.completedOrders.length,
                          itemBuilder: (context, index) {
                            Order order = dataServices.completedOrders[index];
                            return CompletedOrderCard(
                              order: order,
                              onInfoTapped: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(builder: (context) {
                                    return OrderDetailsScreen(
                                      order: order,
                                    );
                                  }),
                                );
                              },
                              onRemoveTapped: () async {
                                ProgressDialog dialog =
                                    new ProgressDialog(context);
                                dialog.style(message: 'Removing...');
                                await dialog.show();
                                NetworkResponse response = await NetworkServices
                                    .shared
                                    .removeOrderFromHistory(
                                        orderId: order.orderId,
                                        orderType: 1,
                                        indexOfOrder: index,
                                        context: context);
                                await dialog.hide();
                                _showSnackBar(response.message);
                              },
                              onRateOrderTapped: () {
                                var message =
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                  MaterialPageRoute(builder: (context) {
                                    return RateOrderScreen(
                                      order: order,
                                      index: index,
                                    );
                                  }),
                                );
                                if (message != null) {
                                  _showSnackBar(message.toString());
                                }
                              },
                            );
                          }),
            ),
            Container(
              child: (_errorMessage != '')
                  ? ErrorText(error: _errorMessage)
                  : dataServices.cancelledOrders.length == 0
                      ? ErrorText(
                          error: 'No cancelled orders available to show')
                      : ListView.builder(
                          itemCount: dataServices.cancelledOrders.length,
                          itemBuilder: (context, index) {
                            Order order = dataServices.cancelledOrders[index];
                            return OtherOrderCard(
                              order: order,
                              onInfoTapped: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(builder: (context) {
                                    return OrderDetailsScreen(
                                      order: order,
                                    );
                                  }),
                                );
                              },
                              onRemoveTapped: () async {
                                ProgressDialog dialog =
                                    new ProgressDialog(context);
                                dialog.style(message: 'Removing...');
                                await dialog.show();
                                NetworkResponse response = await NetworkServices
                                    .shared
                                    .removeOrderFromHistory(
                                        orderId: order.orderId,
                                        orderType: 2,
                                        indexOfOrder: index,
                                        context: context);
                                await dialog.hide();
                                _showSnackBar(response.message);
                              },
                            );
                          }),
            )
          ],
          controller: _controller,
        ),
      );
    });
  }
}

class ErrorText extends StatelessWidget {
  final String error;

  ErrorText({this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: kTextStyleCalibri600.copyWith(fontSize: 16),
      ),
    );
  }
}

class LiveOrderCard extends StatelessWidget {
  final Order order;
  final Function onInfoTapped;
  final Function onTrackTapped;
  final Function onCancelTapped;

  LiveOrderCard(
      {this.order, this.onInfoTapped, this.onTrackTapped, this.onCancelTapped});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderDate,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          ),
                          Text(
                            '#${order.orderId}',
                            style: kTextStyleCalibriBold.copyWith(fontSize: 16),
                          )
                        ],
                      ),
                      Text(
                        order.deliverySlotId == 0
                            ? 'Express Delivery - ${order.deliveryTime}'
                            : 'Scheduled Delivery - ${order.scheduledDeliveryTime}',
                        style: kTextStyleCalibri300.copyWith(fontSize: 16),
                      ),
                      Text(
                        '$kMoneySymbol${order.totalAmount.toStringAsFixed(2)}',
                        style: kTextStyleCalibriBold.copyWith(
                            color: Colors.deepOrange, fontSize: 18),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              order.deliveryAddress,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        order.productName,
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onInfoTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'INFO',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onTrackTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'TRACK',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onCancelTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CANCEL',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class OtherOrderCard extends StatelessWidget {
  final Order order;
  final Function onInfoTapped;
  final Function onRemoveTapped;

  OtherOrderCard({this.order, this.onInfoTapped, this.onRemoveTapped});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderDate,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          ),
                          Text(
                            '#${order.orderId}',
                            style: kTextStyleCalibriBold.copyWith(fontSize: 16),
                          )
                        ],
                      ),
                      Text(
                        order.orderType == 1
                            ? 'Express Delivery - ${order.deliveryTime}'
                            : 'Scheduled Delivery - ${order.deliveryTime}',
                        style: kTextStyleCalibri300.copyWith(fontSize: 16),
                      ),
                      Text(
                        '$kMoneySymbol${order.totalAmount.toStringAsFixed(2)}',
                        style: kTextStyleCalibriBold.copyWith(
                            color: Colors.deepOrange, fontSize: 18),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              order.deliveryAddress,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        order.productName,
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onInfoTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'INFO',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onRemoveTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'REMOVE',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CompletedOrderCard extends StatelessWidget {
  final Order order;
  final Function onInfoTapped;
  final Function onRemoveTapped;
  final Function onRateOrderTapped;

  CompletedOrderCard(
      {this.order,
      this.onInfoTapped,
      this.onRemoveTapped,
      this.onRateOrderTapped});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderDate,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          ),
                          Text(
                            '#${order.orderId}',
                            style: kTextStyleCalibriBold.copyWith(fontSize: 16),
                          )
                        ],
                      ),
                      Text(
                        order.orderType == 1
                            ? 'Express Delivery - ${order.deliveryTime}'
                            : 'Scheduled Delivery - ${order.deliveryTime}',
                        style: kTextStyleCalibri300.copyWith(fontSize: 16),
                      ),
                      Text(
                        '$kMoneySymbol${order.totalAmount.toStringAsFixed(2)}',
                        style: kTextStyleCalibriBold.copyWith(
                            color: Colors.deepOrange, fontSize: 18),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              order.deliveryAddress,
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        order.productName,
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onInfoTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'INFO',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !order.isRatingsGiven,
                            child: GestureDetector(
                              onTap: onRateOrderTapped,
                              child: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'RATE ORDER',
                                    style: kTextStyleCalibriBold.copyWith(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onRemoveTapped,
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'REMOVE',
                                  style: kTextStyleCalibriBold.copyWith(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
