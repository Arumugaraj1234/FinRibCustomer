import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateOrderScreen extends StatefulWidget {
  final Order order;
  final int index;

  RateOrderScreen({this.order, this.index});

  @override
  _RateOrderScreenState createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  @override
  void initState() {
    super.initState();
  }

  double _ratings = 3.0;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (cxt, dataService, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Rate Order',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Container(
                height: 200,
                width: double.infinity,
                child: CarouselSlider(
                  options: CarouselOptions(
                      autoPlay: true, reverse: true, viewportFraction: 1.0),
                  items: widget.order.products
                      .map(
                        (item) => Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(item.imageLink),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Text(
                              item.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HOW WAS EVERYTHING? PLEASE RATE THE ORDER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RatingBar.builder(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _ratings = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          ProgressDialog dialog = new ProgressDialog(context);
                          dialog.style(message: 'Please wait...');
                          await dialog.show();
                          NetworkResponse response =
                              await NetworkServices.shared.applyOrderRatings(
                                  orderId: widget.order.orderId,
                                  ratings: _ratings);
                          await dialog.hide();
                          if (response.code == 1) {
                            dataService.setOrderRatingsStatus(widget.index);
                            Navigator.pop(context, response.message);
                          } else {
                            _showSnackBar(response.message);
                          }
                        },
                        child: Container(
                          color: Colors.deepOrange,
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Text(
                              'UPDATE',
                              style: kTextStyleCalibriBold.copyWith(
                                  fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
