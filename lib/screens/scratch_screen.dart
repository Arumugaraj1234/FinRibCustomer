import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/reward.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/widgets.dart';
import 'package:finandrib/support_files/network_services.dart';

class ScratchScreen extends StatefulWidget {
  final Reward reward;

  ScratchScreen({this.reward});
  @override
  _ScratchScreenState createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  Reward _reward =
      Reward(id: 0, orderId: 0, isScratched: false, orderDate: '', amount: 0);

  @override
  void initState() {
    super.initState();
    setState(() {
      _reward = widget.reward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
              color: Colors.deepOrange.shade100,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 100.0,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              ProgressDialog dialog =
                                  new ProgressDialog(context);
                              dialog.style(message: 'Please wait...');
                              await dialog.show();
                              NetworkResponse response =
                                  await NetworkServices.shared.getProductByShop(
                                      context: context,
                                      shopId: dataServices.selectedShop.id);
                              await dialog.hide();
                              Navigator.popUntil(
                                  context, ModalRoute.withName('HomeScreen'));
                            }),
                      ),
                    ),
                    Scratcher(
                      brushSize: 30,
                      threshold: 50,
                      color: _reward.isScratched
                          ? Colors.transparent
                          : Colors.grey,
                      onChange: (value) {
                        print(value);
                        if (value > 60) {
                          setState(() {
                            _reward.isScratched = true;
                          });
                        }
                      },
                      onThreshold: () async {
                        NetworkResponse response = await NetworkServices.shared
                            .scratchCard(cardId: _reward.id, context: context);
                        if (response.code == 1) {
                          print('Updated successfully');
                        } else {
                          print('Not Updated');
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width - 100,
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset:
                                    Offset(0, 0), // changes position of shadow
                              ),
                            ]),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('images/reward.png'),
                                      fit: BoxFit.scaleDown),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'You won',
                                style: kTextStyleCalibri600.copyWith(
                                    fontSize: 23.0, color: Colors.black87),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '$kMoneySymbol ${_reward.amount.toStringAsFixed(2)}',
                                style: kTextStyleCalibri600.copyWith(
                                  fontSize: 38.0,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Congratulations',
                      style: kTextStyleCalibri600.copyWith(fontSize: 16.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Earned for booking order with Ref: ${_reward.orderId}',
                      style: kTextStyleCalibri300.copyWith(fontSize: 16.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'on ${_reward.orderDate}',
                      style: kTextStyleCalibri300.copyWith(fontSize: 16.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'The amount will be added to wallet once the order got completed',
                      style: kTextStyleCalibri300.copyWith(
                          color: Colors.black, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )),
        ),
      );
    });
  }
}
