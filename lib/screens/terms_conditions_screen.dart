import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finandrib/screens/faq_screen.dart';

class TermsConditionScreen extends StatefulWidget {
  @override
  _TermsConditionScreenState createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FAQModel> _refundPolicies = [
      FAQModel(
          question: "Online Payment",
          answer:
              "Refunds will be processed within 48 hours and will be credited to the "
              "customer account within 5 to 7 working days depending on the issuing bank."),
      FAQModel(
          question: "Cash On Delivery",
          answer: "Refunds will be credited to the customer's account"
              "as store credit and can be used for the subsequent order in the future.")
    ];
    List<FAQModel> _privacyPolicies = [
      FAQModel(
          question: "Privacy Policy",
          answer:
              "This privacy policy sets out how findandrib.com users and protects any information "
              "that you give finandrib.com when you use this website")
    ];
    List<FAQModel> _deliveryPolicies = [
      FAQModel(
          question: "Delivery Information",
          answer:
              "we will deliver your order on chosen delivery date and time. Estimated delivery "
              "time may vary due to shipping practices, based upon delivery location and the  items"
              "you ordered")
    ];

    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          // leading: IconButton(
          //     icon: Icon(
          //       Icons.arrow_back,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     }),
          title: Text(
            'Terms & Conditions',
            style: kTextStyleAppBarTitle,
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            isScrollable: true,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(
                fontFamily: 'Calibri',
                fontWeight: FontWeight.w600,
                fontSize: 16),
            tabs: [
              Tab(
                text: "Refund Policy",
              ),
              Tab(
                text: "Privacy Policy",
              ),
              Tab(
                text: "Delivery Information",
              )
            ],
            onTap: (index) {},
            controller: _controller,
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: ListView.builder(
                  itemCount: _refundPolicies.length,
                  itemBuilder: (context, index) {
                    return QuestionAnswerWidget(_refundPolicies[index]);
                  }),
            ),
            Container(
              child: ListView.builder(
                  itemCount: _privacyPolicies.length,
                  itemBuilder: (context, index) {
                    return QuestionAnswerWidget(_privacyPolicies[index]);
                  }),
            ),
            Container(
              child: ListView.builder(
                  itemCount: _deliveryPolicies.length,
                  itemBuilder: (context, index) {
                    return QuestionAnswerWidget(_deliveryPolicies[index]);
                  }),
            )
          ],
          controller: _controller,
        ),
      );
    });
  }
}
