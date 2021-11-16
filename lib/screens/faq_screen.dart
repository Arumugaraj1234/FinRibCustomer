import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FAQModel {
  String question;
  String answer;

  FAQModel({this.question, this.answer});
}

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQModel> _qandAns = [
    FAQModel(
        question: "Why do you say that your products are chemical free?",
        answer:
            "Our core mission is to provide chemical free, unadulterated food to consumers. "
            "We take great pains to ensure that we go directly to the poultry keepers, fisherman "
            "or farmers without any middle man in between and buy the freshest of fresh food from the source."),
    FAQModel(
        question: "Are you FSSAI registered?",
        answer: "Yes, we are FSSAI registered."),
    FAQModel(
        question: "Are there really chemicals used in fish available locally?",
        answer: "Yes, we have "
            "observed that a large percentage of the fish available in the local market has ammonia or formalin in them."),
    FAQModel(
        question: "Can we test your seafood for formalin or ammonia?",
        answer: "Yes, we have "
            "Yes, you can come visit our store and take a test on our products for formalin or ammonia or any other harmful substances."),
    FAQModel(
        question:
            "How can you confidently say that your meats do not have antibiotics, hormones in them?",
        answer:
            "We, Fin & Rib take great care to ensure there are no growth promoters such as hormones, antibiotics and other bad stuff in the poultry that you buy from us. We ensure that we take the broiler chicken from institutional farmers who are FSSAI/HACCP certified and also conduct lab test on each batch of chicken for the presence of antibiotics or other growth promoters. We also closely keep tab on the product to ensure that the final meat is free of antibiotics before it reaches your doorsteps."),
    FAQModel(
        question: "What about Goat/Mutton or other poultry?",
        answer:
            "In the case of larger animals like goats, quails & country chicken, antibiotics are not needed at any stage as they are sturdier and they are reared in a free range fashion."),
    FAQModel(
        question: "Are all Your Chicken Free Range?",
        answer:
            "No, only the Country Chicken varieties are Free Range birds. The others are reared naturally but not in the open farms which qualify for Free Range rearing."),
    FAQModel(
        question: "How do you manage to deliver it so fresh?",
        answer:
            "Simple - we procure our products from direct sources. At our delivery end, we have a network of vehicles that pick up the product from the airport/train stations and deliver to your doorsteps. We do not depend on any courier companies and have sourcing and delivery fully under our control - while this is expensive, it allows us to give you the best meat & seafood in the fastest time possible from source to destination."),
    FAQModel(
        question: "How fresh is the seafood brought from Fin & Rib?",
        answer:
            "The catch is not treated with chemicals such as formalin, Chlorine or Ammonia, which means what we supply, is the safest and healthiest seafood you can buy. Almost all seafood you find in your local market is invariably treated with one or other chemicals to preserve it. These chemicals are harmful to human beings and actually deprive the seafood of its freshness and natural taste."),
    FAQModel(
        question: "How on time are you delivery guys?",
        answer:
            "We have our own logistics and delivery work force, so we have a fair amount of control on our schedules. The two factors that are not in our control are traffic and unscheduled incidents. However these are extra ordinary situations and barring acts of God, we deliver on time 99.99% of the time."),
    FAQModel(
        question: "What are the delivery charges?",
        answer: "Express Delivery – Rs.15 (Delivery within 1.5 hours)"),
    FAQModel(
        question: "Why do you charge a delivery charge?",
        answer:
            "We provide fish fresher than the fish that you currently get from the market and deliver that at potentially much lower prices than the local market. What this means is that we operate with razor thin margins and for us to break even we need to add a Rs. 15 delivery charge based on the location. As our volumes increase, we are hoping we can lower this cost."),
    FAQModel(
        question: "Are there any delivery timings?",
        answer:
            "We deliver between 10:00 AM to 7:00 PM, on all days, excluding some specific holidays. We cannot determine your exact delivery time, but we can notify you when your order has been shipped out."),
    FAQModel(
        question: "Are your meats Halal Cut?",
        answer:
            "Yes all of our meats are 100% Halal cut by human beings in the proper Halal methodology. The primary benefit with the Halal methodology is that the blood is completely let out from the bird which makes the meat stay longer and is healthier."),
    FAQModel(
        question: "Are there any cleaning charges?",
        answer:
            "No, we do not charge any cleaning charges for Chicken, Seafood & Mutton."),
    FAQModel(
        question: "What are the payment options supported?",
        answer:
            "We support both online as well as cash on delivery payment methods. Payments can be made through website (www.finandrib.com) & also through our android app that can be downloaded from Google Play. Download Link for Fin & Rin App ( https://play.google.com/store/apps/details?id=com.clt.fin_and_rib&hl=en.)"),
    FAQModel(
        question: "Is my credit card information safe on your site?",
        answer:
            "Yes. We do not store credit card details in our system. All online payment related transactions are carried out using trusted CCAvenue backed payment gateway system."),
    FAQModel(
        question:
            "If I pay by net banking / credit card / debit card, how long will it take for my account to be debited?",
        answer:
            "After a successful transaction, your account will get debited immediately."),
    FAQModel(
        question:
            "While I was paying by net banking, my ‘session expired’. What will happen?",
        answer:
            "This happens, simply, when you take too long to make the direct debit/net banking payment and do not manage it in the specified amount of time. Go back to the FinandRib.com site and you will be presented with a page to re-attempt the online payment or convert the order to Cash on Delivery (COD) option."),
    FAQModel(
        question:
            "I made a successful payment by net banking but the system says that the ‘verification has failed’. Now what?",
        answer:
            "To place a successful order, your payment transaction has to get verified successfully at your bank’s direct debit gateway. The verification can fail because of various reasons. If you made a successful payment but the verification failed, do not worry. The amount debited from your account will get credited back within 7 working days."),
    FAQModel(
        question:
            "What if the transaction fails while I am paying online using any payment method?",
        answer:
            "Go back to the FinandRib.com site and you will be presented with a page to re-attempt the online payment or convert the order to Cash on Delivery (COD) option."),
    FAQModel(
        question:
            "I cancelled my order which was made using online payment option (Credit Card/Debit Card/Net Banking). How will I get my money back and when?",
        answer:
            "The account that you used for payment will get credited with the refund amount within 8-9 working days."),
    FAQModel(
        question:
            "My bank is not listed in online payment option, how can I pay?",
        answer:
            "You can use any Visa / MasterCard Credit / Debit Card to pay. In case you don’t have a card, you can use Cash on Delivery option."),
    FAQModel(
        question: "Where is your store located?",
        answer:
            "We are currently in Mogappair East, Chennai 600037. Full address along with contact numbers can be found on ‘contact us’ page."),
    FAQModel(
        question:
            "Do you accept American Express / Sodexo / Gift Vouchers / Meal Pass / other coupons?",
        answer: "No, currently we don't."),
    FAQModel(
        question: "I want to register a feedback/complaint. How do I do it?",
        answer:
            "Please feel free to register your feedbacks/concerns/appreciations and/or complaints at support@finandrib.com or call us."),
    FAQModel(
        question:
            "What do I do if an item is defective (Foul smell or Damaged)?",
        answer:
            "We follow a strict NO QUESTIONS ASKED Return Policy. In case you are not satisfied with a product received, you can return it to the delivery personnel at time of delivery or you can call us we will do the needful."),
    FAQModel(
        question: "Do you deliver in all cities in India?",
        answer: "Currently, we do deliveries in Chennai city only."),
    FAQModel(
        question:
            "Will I be charged any additional fee for using online payment option?",
        answer: "No."),
    FAQModel(
        question: "Is shopping at www.finandrib.com secure?",
        answer:
            "Yes, we have received the Global SSL (Secured socket layer) certification that ensures all the payments made to www.finandrib.com through website and app are safe and secure."),
    FAQModel(
        question: "Why does the price change?",
        answer:
            "Price displayed for the product depends on the market and demand, which will change from time to time."),
    FAQModel(
        question: "How do you send/Deliver the product?",
        answer:
            "It will come in neatly packed paper cart box trays and we will deliver it to you in 'insulated bags' which are temperature controlled."),
  ];

  @override
  Widget build(BuildContext context) {
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
            'FAQ',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: ListView.builder(
            itemCount: _qandAns.length,
            itemBuilder: (context, index) {
              return QuestionAnswerWidget(_qandAns[index]);
            }),
      );
    });
  }
}

class QuestionAnswerWidget extends StatelessWidget {
  final FAQModel model;
  QuestionAnswerWidget(this.model);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            model.question,
            style: TextStyle(
                color: Colors.deepOrange,
                fontFamily: 'Calibri',
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            model.answer,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Calibri',
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}
