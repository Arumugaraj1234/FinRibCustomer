import 'package:finandrib/customized_widgets/custom_tf_one.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/reward.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/widgets.dart';
import 'dart:io' show Platform;

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _isSpinnerToShow = false;
  List<Reward> _allRewards = [];
  String _errorMessage = '';
  Reward _selectedReward;
  bool _isRewardToShowForScratch = false;
  bool _isRedeemScreenToShow = false;
  TextEditingController _redeemTC;
  FocusNode _redeemFN;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _getAllRewards() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    NetworkResponse response =
        await NetworkServices.shared.getAllRewards(context);
    await dialog.hide();
    if (response.code == 1) {
      List<Reward> rewards = response.data;
      setState(() {
        _allRewards = rewards;
        if (rewards.length == 0) {
          _errorMessage = 'No rewards found';
        } else {
          _errorMessage = '';
        }
      });
    } else {
      setState(() {
        _allRewards = [];
        _errorMessage = response.message;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllRewards();
    _redeemTC = new TextEditingController();
    _redeemFN = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _redeemTC.dispose();
    _redeemFN.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          leading: IconButton(
              icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isRewardToShowForScratch = false;
                });
              }),
          title: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Center(
              child: Text(
                'Rewards',
                style: kTextStyleAppBarTitle,
              ),
            ),
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
              child: Container(
                width: 60.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: InkWell(
                  child: Center(
                    child: Text(
                      'REDEEM',
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isRedeemScreenToShow = !_isRedeemScreenToShow;
                    });
                  },
                ),
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    height: 100.0,
                    width: double.infinity,
                    color: Colors.black12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Reward Amount Available',
                          style: kTextStyleCalibri300.copyWith(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          '$kMoneySymbol ${dataServices.walletValue.toStringAsFixed(2)}',
                          style: kTextStyleCalibriBold.copyWith(
                              fontSize: 28.0, color: Colors.deepOrange),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          child: _errorMessage == ''
                              ? AnimationLimiter(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    primary: false,
                                    children: List.generate(
                                      _allRewards.length,
                                      (int index) {
                                        return AnimationConfiguration
                                            .staggeredGrid(
                                          position: index,
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          columnCount: 5,
                                          child: ScaleAnimation(
                                            child: FlipAnimation(
                                              child: RewardsCard(
                                                onTapped: () {
                                                  setState(() {
                                                    _selectedReward =
                                                        _allRewards[index];
                                                    _isRewardToShowForScratch =
                                                        true;
                                                  });
                                                },
                                                reward: _allRewards[index],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _errorMessage,
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 16.0),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: _isRewardToShowForScratch,
              child: Container(
                color: Colors.black87,
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
                                color: Colors.white,
                                size: 30.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isRewardToShowForScratch = false;
                                });
                              }),
                        ),
                      ),
                      Scratcher(
                        brushSize: 30,
                        threshold: 50,
                        color: _selectedReward != null
                            ? (_selectedReward.isScratched
                                ? Colors.transparent
                                : Colors.grey)
                            : Colors.grey,
                        onChange: (value) {
                          print(value);
                          if (value > 60) {
                            setState(() {
                              _selectedReward.isScratched = true;
                            });
                          }
                        },
                        onThreshold: () async {
                          print('You Won, Call web service');
                          NetworkResponse response =
                              await NetworkServices.shared.scratchCard(
                                  cardId: _selectedReward.id, context: context);
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
                          ),
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
                                  '$kMoneySymbol ${_selectedReward != null ? _selectedReward.amount.toStringAsFixed(0) : ''}',
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
                        style: kTextStyleCalibri300.copyWith(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Earned for booking order with Ref: ${_selectedReward != null ? _selectedReward.orderId : ''}',
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.white, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'on ${_selectedReward != null ? _selectedReward.orderDate : ''}',
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.white, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'The amount will be added to wallet once the order got completed',
                        style: kTextStyleCalibri300.copyWith(
                            color: Colors.white, fontSize: 16.0),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isRedeemScreenToShow,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRedeemScreenToShow = false;
                  });
                },
                child: Container(
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(
                      vertical: 100.0, horizontal: 50.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "REDEEM",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            CustomTFOne(
                              controller: _redeemTC,
                              focusNode: _redeemFN,
                              labelText: 'Redeem Code',
                              inputAction: TextInputAction.done,
                              capitalization: TextCapitalization.characters,
                              inputType: TextInputType.name,
                              onSubmitted: (String newValue) {},
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            RaisedButton(
                              onPressed: () async {
                                if (_redeemTC.text != '') {
                                  ProgressDialog dialog =
                                      new ProgressDialog(context);
                                  dialog.style(message: 'Please wait...');
                                  await dialog.show();

                                  NetworkResponse response =
                                      await NetworkServices.shared
                                          .redeemReferralCode(
                                              _redeemTC.text, context);
                                  await dialog.hide();
                                  if (response.code == 1) {
                                    _showSnackBar(
                                        "The redeemed amount got successfully added to your wallet amount");
                                  } else {
                                    _showSnackBar(response.message);
                                  }
                                } else {
                                  _showSnackBar(
                                      "Please provide a valid referral code");
                                }
                              },
                              color: Colors.deepOrange,
                              child: Text(
                                'APPLY',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
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
          ],
        ),
      );
    });
  }
}

class RewardsCard extends StatelessWidget {
  final Function onTapped;
  final Reward reward;
  RewardsCard({this.onTapped, this.reward});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        height: (MediaQuery.of(context).size.width - 60) / 2,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Scratcher(
                brushSize: 30,
                threshold: 50,
                color: reward.isScratched ? Colors.transparent : Colors.grey,
                onChange: (value) => print("Scratch progress: $value%"),
                onThreshold: () => print("Threshold reached, you won!"),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                  image: AssetImage('images/reward.png'),
                                  fit: BoxFit.fitHeight),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  topRight: Radius.circular(5.0))),
                        ),
                      ),
                      Text(
                        'You won',
                        style: kTextStyleCalibri600.copyWith(fontSize: 16.0),
                      ),
                      Text(
                        '$kMoneySymbol ${reward.amount.toStringAsFixed(0)}',
                        style: kTextStyleCalibri600.copyWith(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
              )
            ],
          ),
        ),
      ),
    );
  }
}
