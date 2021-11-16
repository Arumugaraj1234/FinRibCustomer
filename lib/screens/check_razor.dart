import 'package:flutter/material.dart';
import 'package:finandrib/support_files/razorpay_flutter.dart';

class CheckRazor extends StatefulWidget {
  final double totalAmount;
  final String razorApiKey;
  CheckRazor(this.totalAmount, this.razorApiKey);
  @override
  _CheckRazorState createState() => _CheckRazorState();
}

class _CheckRazorState extends State<CheckRazor> {
  Razorpay _razorpay = Razorpay();
  var options;
  Future payData() async {
    print('Pay Data');
    try {
      print('Pay Data 1');
      _razorpay.open(options);
    } catch (e) {
      print('Pay Data2');
      print("errror occured here is ......................./:$e");
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("payment has succedded ${response.toString()}");
//    Navigator.pushAndRemoveUntil(
//      context,
//      MaterialPageRoute(
//        builder: (BuildContext context) => SuccessPage(
//          response: response,
//        ),
//      ),
//          (Route<dynamic> route) => false,
//    );
    Map<String, dynamic> resValue = {'code': 1, 'data': response};
    Navigator.pop(context, resValue);
    _razorpay.clear();
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        "payment has error00000000000000000000000000000000000000 ${response.toString()}");
    // Do something when payment fails
//    Navigator.pushAndRemoveUntil(
//      context,
//      MaterialPageRoute(
//        builder: (BuildContext context) => FailedPage(
//          response: response,
//        ),
//      ),
//          (Route<dynamic> route) => false,
//    );
    Map<String, dynamic> resValue = {'code': 0, 'data': response};
    Navigator.pop(context, resValue);
    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("payment has externalWallet33333333333333333333333333");
//    Navigator.pop(context, response);
    _razorpay.clear();
    // Do something when an external wallet is selected
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    options = {
      'key':
          widget.razorApiKey, // Enter the Key ID generated from the Dashboard

      'amount': widget.totalAmount * 100, //in the smallest currency sub-unit.
      'name': "Fin & Rib",

      'currency': "INR",
      'theme.color': "#F37254",
      'buttontext': "Pay with Razorpay",
      'description': 'Amount to pay',
      'prefill': {
        'contact': '',
        'email': '',
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // print("razor runtime --------: ${_razorpay.runtimeType}");
    return Scaffold(
      body: FutureBuilder(
          future: payData(),
          builder: (context, snapshot) {
            return Container(
              child: Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
