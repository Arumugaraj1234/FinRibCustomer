import 'dart:convert';

import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/models/reward.dart';
import 'package:finandrib/models/selected_product_model.dart';
import 'package:finandrib/screens/check_razor.dart';
import 'package:finandrib/screens/delivery_type_screen.dart';
import 'package:finandrib/screens/scratch_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:finandrib/support_files/razorpay_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_sound/flutter_sound.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
//import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

// typedef _Fn = void Function();
// const theSource = AudioSource.microphone;

enum PaymentOption { onlinePayment, cashOnDelivery, cardPayment }

class OrderConfirmationScreen extends StatefulWidget {
  final DeliveryType deliveryType;
  final DateDetail selectedDate;
  final TimeSlot selectedTimeSlot;
  final Wallet wallet;

  OrderConfirmationScreen(
      {this.deliveryType,
      this.selectedDate,
      this.selectedTimeSlot,
      this.wallet});

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  PaymentOption _paymentOption = PaymentOption.cashOnDelivery;
  String _paymentMethod = 'Cash On Delivery';
  TextEditingController _couponTC = new TextEditingController();
  FocusNode _couponFN = new FocusNode();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isWalletUsed = false;
  int _walletAlertFlag = 0;

  int noOfItems = 0;
  bool isOfferAdded = false;

  //todo: Sound recordings

  /* File soundFile;
  Codec _codec = Codec.aacMP4;
  String _mPath = '';
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  void stopPlayer() {
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

  void play() async {
    print("Aru $_mPath");
    soundFile = File(_mPath);
    //soundFile.openRead();
    var bytes = soundFile.readAsBytesSync();
    String base64 = base64Encode(bytes);
    log(base64);

    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer
        .startPlayer(
            fromURI: _mPath,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
  }

  void record() {
    _mRecorder
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      print("ARUMUGARAJ $_mPath");
      soundFile = File(_mPath);
      var bytes = soundFile.readAsBytes();
      print(bytes);

      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        _mplaybackReady = true;
      });
    });
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _mRecorder.openAudioSession();
    if (!await _mRecorder.isEncoderSupported(_codec)) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder.isEncoderSupported(_codec)) {
        _mRecorderIsInited = true;
        return;
      }
    }
    _mRecorderIsInited = true;
  }

  _setFilePath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    _mPath = documentDirectory.path + 'tau_file.mp4';
  }*/

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void dispose() {
    // _mPlayer.closeAudioSession();
    // _mPlayer = null;
    //
    // _mRecorder.closeAudioSession();
    // _mRecorder = null;
    super.dispose();
    _couponTC.dispose();
    _couponFN.dispose();
  }

  @override
  void initState() {
    /*_mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    _setFilePath();*/
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // List<Product> products =
      //     Provider.of<DataServices>(context, listen: false).selectedProducts;
      // int a = products.length;
      Product p = Provider.of<DataServices>(context, listen: false)
          .selectedOfferProduct;
      print("Raj $p");

      if (p != null) {
        setState(() {
          noOfItems = 1;
        });
      }
    });
    super.initState();
    _couponFN.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    debugPrint("Focus: " + _couponFN.hasFocus.toString());
  }

  // MediaQuery.of(context).size.height -
  // AppBar().preferredSize.height -
  // 25

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (cxt, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Check Out',
            style: kTextStyleAppBarTitle,
          ),
          /* actions: [
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.mic,
                  size: 25,
                ),
              ),
            )
          ],*/
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top, //91
            child: Column(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: Offset(0, 3))
                  ], color: Colors.white),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _paymentOption = PaymentOption.cashOnDelivery;
                              _paymentMethod = 'Cash On Delivery';
                            });
                          },
                          child: Container(
                            height: 90,
                            width: 110,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _paymentOption ==
                                            PaymentOption.cashOnDelivery
                                        ? Colors.deepOrange
                                        : Colors.grey,
                                    width: _paymentOption ==
                                            PaymentOption.cashOnDelivery
                                        ? 3
                                        : 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                )),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Cash On Delivery',
                                  style: kTextStyleCalibri600.copyWith(
                                      fontSize: 13),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 50,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/cash_icon.png'),
                                                fit: BoxFit.fill)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _paymentOption = PaymentOption.onlinePayment;
                              _paymentMethod = 'Pay Online';
                            });
                          },
                          child: Container(
                            height: 90,
                            width: 110,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _paymentOption ==
                                            PaymentOption.onlinePayment
                                        ? Colors.deepOrange
                                        : Colors.grey,
                                    width: _paymentOption ==
                                            PaymentOption.onlinePayment
                                        ? 3
                                        : 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                )),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Pay Online',
                                    style: kTextStyleCalibri600.copyWith(
                                        fontSize: 13)),
                                Expanded(
                                  child: Container(
                                    child: Center(
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/pay_online_icon.png'),
                                                fit: BoxFit.fitHeight)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _paymentOption = PaymentOption.cardPayment;
                              _paymentMethod = 'Card Payment';
                            });
                          },
                          child: Container(
                            height: 90,
                            width: 110,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _paymentOption ==
                                            PaymentOption.cardPayment
                                        ? Colors.deepOrange
                                        : Colors.grey,
                                    width: _paymentOption ==
                                            PaymentOption.cardPayment
                                        ? 3
                                        : 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                )),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Card Swipe Payment',
                                    style: kTextStyleCalibri600.copyWith(
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Center(
                                      child: Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/pay_card_icon.png'),
                                                fit: BoxFit.fitWidth)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    child: ListView(
                      children: [
                        /*Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Record Your Special Instruction here',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    //onTap: getRecorderFn(),
                                    onLongPress: getRecorderFn(),
                                    onLongPressUp: getRecorderFn(),
                                    child: Icon(
                                      Icons.mic,
                                      size: 30,
                                      color: _mRecorder.isRecording
                                          ? Colors.green
                                          : Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: getPlaybackFn(),
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),*/
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight:
                                  dataServices.selectedProducts.length * 100.0,
                              minHeight:
                                  dataServices.selectedProducts.length * 50.0),
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: dataServices.selectedProducts.length,
                              itemBuilder: (context, index) {
                                List<Product> products =
                                    dataServices.selectedProducts;
                                Product product = products[index];
                                return CheckOutProductCard(
                                  product: product,
                                  onMinusPressed: () {
                                    if (dataServices
                                            .selectedProducts[index].count >
                                        1) {
                                      dataServices
                                          .removeItemInSelectedDishes(index);
                                      dataServices.setWalletUsablePercentage(
                                          widget.wallet.usablePercentage,
                                          widget
                                              .wallet.minBillAmountForDiscount);
                                    }
                                  },
                                  onPlusPressed: () {
                                    // dataServices.setWalletUsablePercentage(
                                    //     widget.wallet.usablePercentage,
                                    //     widget.wallet.minBillAmountForDiscount);
                                    dataServices.addItemInSelectedDishes(index);
                                    dataServices.setWalletUsablePercentage(
                                        widget.wallet.usablePercentage,
                                        widget.wallet.minBillAmountForDiscount);
                                  },
                                  slNo: index + 1,
                                );
                              }),
                        ),
                        dataServices.selectedOfferProduct != null
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 100.0, minHeight: 50.0),
                                child: CheckOutProductCard(
                                  product: dataServices.selectedOfferProduct,
                                  onMinusPressed: () {},
                                  onPlusPressed: () {},
                                  slNo:
                                      dataServices.selectedProducts.length + 1,
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              DotView(),
                              Text(
                                'Shipping Address',
                                style: kTextStyleCalibriBold.copyWith(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  dataServices.selectedAddress.fullAddress,
                                  style: kTextStyleCalibri300.copyWith(
                                      fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              DotView(),
                              Text(
                                'Delivery Date',
                                style: kTextStyleCalibriBold.copyWith(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  widget.deliveryType ==
                                          DeliveryType.scheduledDelivery
                                      ? '${widget.selectedDate.fullDate}, ${widget.selectedTimeSlot.name}'
                                      : 'Your order will be delivered with in 90 minutes',
                                  style: kTextStyleCalibri300.copyWith(
                                      fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              DotView(),
                              Text(
                                'Payment Method',
                                style: kTextStyleCalibriBold.copyWith(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  _paymentMethod,
                                  style: kTextStyleCalibri300.copyWith(
                                      fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(),
                        ),
                        Center(
                          child: Container(
                            height: 100,
                            width: 300,
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 7,
                                  spreadRadius: 3,
                                  offset: Offset(2, 3))
                            ]),
                            child: Row(
                              children: [
                                CustomPaint(
                                  size: Size(0, 100),
                                  painter: MyPainter(),
                                ),
                                Container(
                                  width: 50,
                                  color: Colors.deepOrange,
                                  child: Center(
                                    child: RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        'YOUR WALLET AMOUNT',
                                        style: kTextStyleCalibri600.copyWith(
                                            color: Colors.white, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '✭',
                                              style:
                                                  kTextStyleCalibri600.copyWith(
                                                      color: Colors.deepOrange,
                                                      fontSize: 14),
                                            ),
                                            Text(
                                              'YOUR WALLET EARN AMOUNT',
                                              style: kTextStyleCalibri600
                                                  .copyWith(fontSize: 15),
                                            ),
                                            Text(
                                              '✭',
                                              style:
                                                  kTextStyleCalibri600.copyWith(
                                                      color: Colors.deepOrange,
                                                      fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$kMoneySymbol',
                                              style:
                                                  kTextStyleCalibri300.copyWith(
                                                      color: Colors.deepOrange,
                                                      fontSize: 40),
                                            ),
                                            Text(
                                              dataServices.walletValue
                                                  .toStringAsFixed(0),
                                              style: kTextStyleCalibri600
                                                  .copyWith(fontSize: 40),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'DISCOUNT VOUCHER',
                                          style: kTextStyleCalibri300.copyWith(
                                              color: Colors.grey, fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                CustomPaint(
                                  size: Size(0, 100),
                                  painter: MyPainterOne(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'APPLY COUPON CODE:',
                              style: kTextStyleCalibri600.copyWith(fontSize: 16),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 35,
                              width: 150,
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                  hintText: 'Coupon Code',
                                  contentPadding: EdgeInsets.all(0),
                                ),
                                controller: _couponTC,
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.characters,
                                onSubmitted: (newValue) {
                                  print(newValue);
                                },
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.center,
                                style: kTextStyleCalibri300.copyWith(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_couponTC.text != '') {
                                  ProgressDialog dialog =
                                      new ProgressDialog(context);
                                  dialog.style(message: 'Please wait...');
                                  await dialog.show();
                                  NetworkResponse response =
                                      await NetworkServices.shared.applyPromoCode(
                                          promo: _couponTC.text,
                                          shopId: dataServices.selectedShop.id,
                                          context: context);
                                  await dialog.hide();
                                  if (response.code != 1) {
                                    _showSnackBar(response.message);
                                  }
                                } else {
                                  _showSnackBar("The coupon code can't be empty");
                                }
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.deepOrange,
                                size: 25,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 100,
                        )*/
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: _couponFN.hasFocus ? 350 : 270,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: Offset(0, -3))
                  ], color: Colors.white),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    '* Wallet amount can be utilized only with min. purchase of $kMoneySymbol${widget.wallet.minBillAmountForDiscount.toStringAsFixed(2)}/-',
                                    style: kTextStyleCalibri300.copyWith(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'APPLY COUPON CODE:',
                                    style: kTextStyleCalibri600.copyWith(
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 35,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(),
                                          ),
                                          hintText: 'Coupon Code',
                                          contentPadding: EdgeInsets.all(0),
                                        ),
                                        controller: _couponTC,
                                        focusNode: _couponFN,
                                        textInputAction: TextInputAction.done,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        onSubmitted: (newValue) {
                                          print(newValue);
                                        },
                                        onChanged: (newValue) {
                                          dataServices.setPromoOffer(null);
                                        },
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.center,
                                        style: kTextStyleCalibri300.copyWith(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      if (_couponTC.text != '') {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Please wait...');
                                        await dialog.show();
                                        NetworkResponse response =
                                            await NetworkServices.shared
                                                .applyPromoCode(
                                                    promo: _couponTC.text,
                                                    shopId: dataServices
                                                        .selectedShop.id,
                                                    context: context);
                                        await dialog.hide();
                                        if (response.code != 1) {
                                          _showSnackBar(response.message);
                                        }
                                      } else {
                                        _showSnackBar(
                                            "The coupon code can't be empty");
                                      }
                                    },
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.deepOrange,
                                      size: 25,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: _couponFN.hasFocus ? 80 : 5,
                              ),
                              Row(
                                children: [
                                  DotView(),
                                  Text(
                                    'Payment Summary',
                                    style: kTextStyleCalibriBold.copyWith(
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Total',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                      '$kMoneySymbol${dataServices.selectedProductsTotalPrice.toStringAsFixed(2)}/-',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16))
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Delivery Fee',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                      '$kMoneySymbol${dataServices.deliveryCharge.toStringAsFixed(2)}/-',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16))
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Wallet Amount',
                                          style: kTextStyleCalibri300.copyWith(
                                              fontSize: 16),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_isWalletUsed) {
                                              dataServices
                                                  .setWalletUsablePercentage(
                                                      0,
                                                      widget.wallet
                                                          .minBillAmountForDiscount);
                                              setState(() {
                                                _isWalletUsed = !_isWalletUsed;
                                              });

                                              if (_walletAlertFlag == 0) {
                                                NetworkServices.shared
                                                    .showAlertDialog(
                                                        context,
                                                        'Wallet usage alert',
                                                        'For the first two orders, can use the wallet amount partially and after that you can use that fully',
                                                        () {
                                                  Navigator.pop(context);
                                                });
                                              }

                                              _walletAlertFlag++;
                                            } else {
                                              dataServices
                                                  .setWalletUsablePercentage(
                                                      widget.wallet
                                                          .usablePercentage,
                                                      widget.wallet
                                                          .minBillAmountForDiscount);
                                              setState(() {
                                                _isWalletUsed = !_isWalletUsed;
                                              });
                                            }
                                          },
                                          child: Icon(
                                            _isWalletUsed
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                      '$kMoneySymbol${dataServices.walletAmountUsed.toStringAsFixed(2)}/-',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16))
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Coupon Amount',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                      '$kMoneySymbol${dataServices.discountAmount.toStringAsFixed(2)}/-',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16))
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'GST',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                      '$kMoneySymbol${dataServices.gst.toStringAsFixed(2)}/-',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16))
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "You'll earn",
                                      style: kTextStyleCalibri600.copyWith(
                                          fontSize: 14, color: Colors.green),
                                    ),
                                  ),
                                  Text(
                                    '14 TC Rewards Cash',
                                    style: kTextStyleCalibri600.copyWith(
                                        fontSize: 14, color: Colors.green),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 40.0,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                              color: Colors.black,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Total',
                                        style: kTextStyleCalibri600.copyWith(
                                            fontSize: 16.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$kMoneySymbol ${dataServices.grandTotal.toStringAsFixed(2)}',
                                        style: kTextStyleCalibri600.copyWith(
                                            fontSize: 16.0,
                                            color: Colors.deepOrange),
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
                                    if (dataServices
                                            .selectedProductsTotalPrice >
                                        0) {
                                      List<SelectedProduct> selectedproducts =
                                          [];
                                      List<Product> selected =
                                          dataServices.selectedProducts;
                                      print(selected);
                                      for (var sel in selected) {
                                        print(sel.name);
                                        SelectedProduct s = SelectedProduct(
                                            dish_id: sel.id,
                                            qty: sel.count,
                                            cutSize: sel.cuttingSize,
                                            itemSize: sel.itemSize,
                                            rate: sel.totalPrice,
                                            offerFlag: 0);
                                        selectedproducts.add(s);
                                      }

                                      if (dataServices.selectedOfferProduct !=
                                          null) {
                                        Product p =
                                            dataServices.selectedOfferProduct;
                                        print(p.name);
                                        SelectedProduct s = SelectedProduct(
                                            dish_id: p.id,
                                            qty: p.count,
                                            cutSize: p.cuttingSize,
                                            itemSize: p.itemSize,
                                            rate: p.totalPrice,
                                            offerFlag: p.offerId);
                                        selectedproducts.add(s);
                                      }

                                      print(selectedproducts);

                                      if (_paymentOption ==
                                          PaymentOption.onlinePayment) {
                                        if (dataServices.grandTotal > 0) {
                                          ProgressDialog dialog =
                                              new ProgressDialog(context);
                                          dialog.style(
                                              message: 'Saving order...');
                                          await dialog.show();
                                          NetworkResponse response = await NetworkServices.shared.placeOrder(
                                              hotelId:
                                                  dataServices.selectedShop.id,
                                              orderType: widget.deliveryType ==
                                                      DeliveryType
                                                          .expressDelivery
                                                  ? 1
                                                  : 2,
                                              address:
                                                  dataServices.selectedAddress,
                                              paymentType: 2,
                                              dishes: selectedproducts,
                                              couponCode: dataServices.promoOffer != null
                                                  ? dataServices
                                                      .promoOffer.promoCode
                                                  : '',
                                              couponType: dataServices.promoOffer != null
                                                  ? dataServices
                                                      .promoOffer.promoTypeFlag
                                                  : 0,
                                              transactionId: '',
                                              walletAmount:
                                                  dataServices.walletAmountUsed,
                                              splInst: '',
                                              deliveryTime: widget.selectedDate != null
                                                  ? widget.selectedDate.fullDate
                                                  : '05-Mar-2021',
                                              deliverySlotId:
                                                  widget.selectedTimeSlot != null
                                                      ? widget.selectedTimeSlot.id
                                                      : 0,
                                              deliveryCharge: dataServices.deliveryCharge,
                                              gst: dataServices.gst);
                                          await dialog.hide();
                                          if (response.code == 2) {
                                            int orderId = response.data;
                                            Map<String, dynamic>
                                                paymentResponse =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                double gTotal = double.parse(
                                                    (dataServices.grandTotal)
                                                        .toStringAsFixed(2));
                                                return CheckRazor(gTotal,
                                                    dataServices.razorPayKey);
                                              }),
                                            );

                                            if (paymentResponse != null) {
                                              if (paymentResponse['code'] ==
                                                  1) {
                                                print('One');
                                                ProgressDialog dialog =
                                                    new ProgressDialog(context);
                                                dialog.style(
                                                    message: 'Saving order...');
                                                await dialog.show();
                                                PaymentSuccessResponse
                                                    payResponse =
                                                    paymentResponse['data'];
                                                String txnId =
                                                    payResponse.paymentId;
                                                NetworkResponse response =
                                                    await NetworkServices.shared
                                                        .updatePaymentStatus(
                                                            orderId: orderId,
                                                            txnId: txnId,
                                                            payResponse: 1);
                                                await dialog.hide();
                                                if (response.code == 1) {
                                                  NetworkServices.shared
                                                      .showAlertDialog(
                                                          context,
                                                          'Success',
                                                          response.message,
                                                          () async {
                                                    await NetworkServices.shared
                                                        .getOrdersHistory(
                                                            context: context);
                                                    dataServices
                                                        .getBackToHomeAfterCompleteOrder();
                                                    Reward reward =
                                                        response.data;
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return ScratchScreen(
                                                        reward: reward,
                                                      );
                                                    }));
                                                  });
                                                } else {
                                                  NetworkServices.shared
                                                      .showAlertDialog(
                                                          context,
                                                          'Failed',
                                                          response.message, () {
                                                    Navigator.pop(context);
                                                  });
                                                }
                                              } else {
                                                ProgressDialog dialog =
                                                    new ProgressDialog(context);
                                                dialog.style(
                                                    message: 'Please wait...');
                                                await dialog.show();
                                                NetworkResponse response =
                                                    await NetworkServices.shared
                                                        .updatePaymentStatus(
                                                            orderId: orderId,
                                                            txnId: '',
                                                            payResponse: 2);
                                                await dialog.hide();
                                                PaymentFailureResponse
                                                    errResponse =
                                                    paymentResponse['data'];
                                                var errorResponsea =
                                                    json.decode(
                                                        errResponse.message);
                                                print(
                                                    'AruError: $errorResponsea');
                                                var errora =
                                                    errorResponsea['error']
                                                        ['description'];
                                                //print(errora);
                                                _showSnackBar(errora);
                                              }
                                            } else {
                                              ProgressDialog dialog =
                                                  new ProgressDialog(context);
                                              dialog.style(
                                                  message: 'Please wait...');
                                              await dialog.show();
                                              NetworkResponse response =
                                                  await NetworkServices.shared
                                                      .updatePaymentStatus(
                                                          orderId: orderId,
                                                          txnId: '',
                                                          payResponse: 3);
                                              await dialog.hide();
                                              _showSnackBar(
                                                  'Payment got cancelled');
                                            }
                                          }
                                          else if (response.code == 3){
NetworkServices.shared
    .showAlertDialog(
    context,
    'Failed',
    response.message, () {
      dataServices.removeSelectedOfferProduct();
  Navigator.pop(context);
});
                                          }
                                          else {
                                            _showSnackBar(response.message);
                                          }
                                        } else {
                                          _showSnackBar(
                                              'Order value is 0. Please book as Cash on Delivery');
                                        }
                                      } else {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(
                                            message: 'Saving order...');
                                        await dialog.show();
                                        NetworkResponse response = await NetworkServices.shared.placeOrder(
                                            hotelId:
                                                dataServices.selectedShop.id,
                                            orderType: widget.deliveryType ==
                                                    DeliveryType.expressDelivery
                                                ? 1
                                                : 2,
                                            address:
                                                dataServices.selectedAddress,
                                            paymentType: _paymentOption ==
                                                    PaymentOption.cashOnDelivery
                                                ? 1
                                                : 3,
                                            dishes: selectedproducts,
                                            couponCode: dataServices.promoOffer != null
                                                ? dataServices
                                                    .promoOffer.promoCode
                                                : '',
                                            couponType: dataServices.promoOffer != null
                                                ? dataServices
                                                    .promoOffer.promoTypeFlag
                                                : 0,
                                            transactionId: '',
                                            walletAmount:
                                                dataServices.walletAmountUsed,
                                            splInst: '',
                                            deliveryTime: widget.selectedDate != null
                                                ? widget.selectedDate.fullDate
                                                : '05-Mar-2021',
                                            deliverySlotId: widget.selectedTimeSlot != null ? widget.selectedTimeSlot.id : 0,
                                            deliveryCharge: dataServices.deliveryCharge,
                                            gst: dataServices.gst);
                                        await dialog.hide();
                                        if (response.code == 1) {
                                          NetworkServices.shared
                                              .showAlertDialog(
                                                  context,
                                                  'Success',
                                                  response.message, () async {
                                            await NetworkServices.shared
                                                .getOrdersHistory(
                                                    context: context);
                                            dataServices
                                                .getBackToHomeAfterCompleteOrder();
                                            Reward reward = response.data;
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ScratchScreen(
                                                reward: reward,
                                              );
                                            }));
                                          });
                                        } else if (response.code == 3){
                                          NetworkServices.shared
                                              .showAlertDialog(
                                              context,
                                              'Failed',
                                              response.message, () {
                                            dataServices.removeSelectedOfferProduct();
                                            Navigator.pop(context);
                                          });
                                        }else {
                                          NetworkServices.shared
                                              .showAlertDialog(
                                                  context,
                                                  'Failed',
                                                  response.message, () {
                                            Navigator.pop(context);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: Text(
                                    'BOOK ORDER',
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
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CheckOutProductCard extends StatelessWidget {
  final Product product;
  final Function onMinusPressed;
  final Function onPlusPressed;
  final int slNo;

  CheckOutProductCard(
      {this.product, this.onMinusPressed, this.onPlusPressed, this.slNo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text(
                '$slNo.',
                style: kTextStyleCalibri600.copyWith(fontSize: 16),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  color: Colors.green,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3,
                      spreadRadius: 2,
                      offset: Offset(0, 0),
                    )
                  ],
                  image: DecorationImage(
                      image: NetworkImage(product.thumbNail), fit: BoxFit.fill),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      product.name,
                      style: kTextStyleCalibriBold.copyWith(
                          color: Colors.deepOrange, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'QTY: (${product.productGrams().toStringAsFixed(0)} ${product.initialUom()}) ${product.count} x \u{20B9}${product.price}',
                      style: kTextStyleCalibri300.copyWith(fontSize: 15),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            /* GestureDetector(
                              onTap: onMinusPressed,
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.deepOrange,
                                size: 20,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),*/
                            Text(
                              product.count.toString(),
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                            /*SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: onPlusPressed,
                              child: Icon(
                                Icons.add_circle,
                                color: Colors.deepOrange,
                                size: 20,
                              ),
                            ),*/
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text("-"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${product.unitOfMeasurement() == "Grams" ? product.totalGrams().toStringAsFixed(0) : product.totalGrams().toStringAsFixed(3)} ${product.unitOfMeasurement()}',
                          style: kTextStyleCalibri300.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '$kMoneySymbol${product.totalPrice.toStringAsFixed(2)}',
                style: kTextStyleCalibri600.copyWith(fontSize: 15),
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}

class DotView extends StatelessWidget {
  const DotView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      child: Center(
        child: Container(
          height: 6,
          width: 6,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.all(
              Radius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.deepOrange;
    paint.style = PaintingStyle.fill;

    paintZigZag(canvas, paint, Offset(0, 100), Offset(0, 0), 20, 5);
  }

  void paintZigZag(Canvas canvas, Paint paint, Offset start, Offset end,
      int zigs, double width) {
    assert(zigs.isFinite);
    assert(zigs > 0);
    canvas.save();
    canvas.translate(start.dx, start.dy);
    end = end - start;
    canvas.rotate(math.atan2(end.dy, end.dx));
    final double length = end.distance;
    final double spacing = length / (zigs * 2.0);
    final Path path = Path()..moveTo(0.0, 0.0);
    for (int index = 0; index < zigs; index += 1) {
      final double x = (index * 2.0 + 1.0) * spacing;
      final double y = width * ((index % 2.0) * 2.0 - 1.0);
      path.lineTo(x, y);
    }
    path.lineTo(length, 0.0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyPainterOne extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;

    paintZigZag(canvas, paint, Offset(0, 100), Offset(0, 0), 20, 5);
  }

  void paintZigZag(Canvas canvas, Paint paint, Offset start, Offset end,
      int zigs, double width) {
    assert(zigs.isFinite);
    assert(zigs > 0);
    canvas.save();
    canvas.translate(start.dx, start.dy);
    end = end - start;
    canvas.rotate(math.atan2(end.dy, end.dx));
    final double length = end.distance;
    final double spacing = length / (zigs * 2.0);
    final Path path = Path()..moveTo(0.0, 0.0);
    for (int index = 0; index < zigs; index += 1) {
      final double x = (index * 2.0 + 1.0) * spacing;
      final double y = width * ((index % 2.0) * 2.0 - 1.0);
      path.lineTo(x, y);
    }
    path.lineTo(length, 0.0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
