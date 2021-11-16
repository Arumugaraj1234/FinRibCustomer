import 'dart:async';

import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  final int index;
  OrderDetailsScreen({this.order, this.index});
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order _order;
  int _riderId = 0;
  Timer _timerToGetRiderId;

  @override
  void initState() {
    super.initState();
    setState(() {
      _order = widget.order;
      _riderId = widget.order.riderId;
    });
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
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        child: Column(
          children: <Widget>[
            Container(
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0)),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _order.orderDate,
                                style: kTextStyleCalibri300.copyWith(
                                    color: Colors.white, fontSize: 13.0),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _order.deliverySlotId == 0
                                    ? "Express Delivery"
                                    : "Scheduled Delivery",
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                                style: kTextStyleCalibri300.copyWith(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'Delivery Time:',
                          style: kTextStyleCalibri300.copyWith(
                              color: Colors.white, fontSize: 13.0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Text(
                          _order.deliverySlotId == 0
                              ? _order.deliveryTime
                              : _order.scheduledDeliveryTime,
                          style: kTextStyleCalibri300.copyWith(
                              color: Colors.white, fontSize: 13.0),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 54.0,
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 9.0,
                              ),
                              Container(
                                height: 6.0,
                                width: 6.0,
                                color: Colors.green,
                              ),
                              SizedBox(
                                height: 2.0,
                              ),
                              Container(
                                height: 20.0,
                                width: 10.0,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 4.0,
                                    ),
                                    Dash(
                                      direction: Axis.vertical,
                                      dashColor: Colors.white,
                                      length: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2.0,
                              ),
                              Container(
                                height: 6.0,
                                width: 6.0,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(children: <Widget>[
                              Flexible(
                                child: Container(
                                  height: 24.0,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _order.fromLocation,
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: kTextStyleCalibri300.copyWith(
                                          color: Colors.white, fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Flexible(
                                child: Container(
                                  height: 24.0,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _order.deliveryAddress == ''
                                          ? '---'
                                          : _order.deliveryAddress,
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: kTextStyleCalibri300.copyWith(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.adjust,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _order.orderStatusDesc,
                                style: kTextStyleCalibri300.copyWith(
                                  color: Colors.orange,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Items',
                                style: kTextStyleCalibri600.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          )),
                          Container(
                            width: 100.0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Price',
                                style: kTextStyleCalibri600.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Dash(
                      direction: Axis.horizontal,
                      dashColor: Colors.black,
                      length: MediaQuery.of(context).size.width - 50,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: Container(
                        child: ListView(
                            children: List.generate(_order.products.length,
                                (int index) {
                          String cutAndSize = '';
                          String cuttingSize =
                              _order.products[index].cuttingSize;
                          String productSize =
                              _order.products[index].itemSizeOption;
                          if (cuttingSize != '' && productSize != '') {
                            cuttingSize = '( $cuttingSize & $productSize)';
                          } else if (cuttingSize != '' && productSize == '') {
                            cuttingSize = '( $cuttingSize )';
                          } else if (cuttingSize == '' && productSize != '') {
                            cuttingSize = '( $productSize)';
                          } else {
                            cuttingSize = '';
                          }

                          return Container(
                            height: 35.0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${_order.products[index].name} $cuttingSize x ${_order.products[index].count}',
                                      style: kTextStyleCalibri600.copyWith(
                                        color: Colors.black54,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                )),
                                Container(
                                  width: 100.0,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${kMoneySymbol}${_order.products[index].totalPrice.toStringAsFixed(2)}',
                                      style: kTextStyleCalibri600.copyWith(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        })),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Dash(
                      direction: Axis.horizontal,
                      dashColor: Colors.black,
                      length: MediaQuery.of(context).size.width - 50,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Items Total',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14),
                          ),
                        ),
                        Text('$kMoneySymbol${_order.amount.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Delivery Charge',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14),
                          ),
                        ),
                        Text(
                            '$kMoneySymbol${_order.deliveryCharge.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Wallet Used',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14),
                          ),
                        ),
                        Text(
                            '$kMoneySymbol${_order.walletUsed.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Coupen Amount',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14),
                          ),
                        ),
                        Text(
                            '$kMoneySymbol${_order.discount.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'GST',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14),
                          ),
                        ),
                        Text('$kMoneySymbol${_order.tax.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 35.0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Total',
                                    style: kTextStyleCalibri600.copyWith(
                                        color: Colors.black, fontSize: 16.0),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '',
                                      style: kTextStyleCalibri600.copyWith(
                                          color: Colors.black54,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Container(
                            width: 100.0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$kMoneySymbol${_order.totalAmount.toStringAsFixed(2)}',
                                style: kTextStyleCalibri600.copyWith(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
