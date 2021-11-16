import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/shop.dart';
import 'package:finandrib/screens/cart_screen.dart';
import 'package:finandrib/screens/category_screen.dart';
import 'package:finandrib/screens/error_message_screen.dart';
import 'package:finandrib/screens/order_history_screen.dart';
import 'package:finandrib/screens/profile_screen.dart';
import 'package:finandrib/screens/search_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  DateTime currentBackPressTime;
  List<Shop> _shops = [];
  final _items = [
    BottomNavigationBarItem(
      icon: Image.asset('images/home_icon.png'),
      title: Text(
        'HOME',
        style: TextStyle(
            fontFamily: 'Calibri', fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    BottomNavigationBarItem(
      icon: Image.asset('images/myorder_icon.png'),
      title: Text(
        'MY ORDER',
        style: TextStyle(
            fontFamily: 'Calibri', fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    BottomNavigationBarItem(
      icon: Image.asset('images/cart_icon.png'),
      title: Text(
        'MY CART',
        style: TextStyle(
            fontFamily: 'Calibri', fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    BottomNavigationBarItem(
      icon: Image.asset('images/search_icon.png'),
      title: Text(
        'SEARCH',
        style: TextStyle(
            fontFamily: 'Calibri', fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    BottomNavigationBarItem(
      icon: Image.asset('images/profile_icon.png'),
      title: Text(
        'PROFILE',
        style: TextStyle(
            fontFamily: 'Calibri', fontSize: 11, fontWeight: FontWeight.w600),
      ),
    )
  ];

  BuildContext _ctx;

  void _showSnackBar(String text) {
    Fluttertoast.showToast(msg: text, toastLength: Toast.LENGTH_LONG);
  }

  void _getAllShops() async {
    NetworkResponse response =
        await NetworkServices.shared.getAllShops(context: context);
  }

  @override
  void initState() {
    super.initState();
    //_getAllShops();
  }

  void _getOrdersHistory() async {
    NetworkResponse response =
        await NetworkServices.shared.getOrdersHistory(context: context);
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return WillPopScope(
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: _items,
            backgroundColor: Colors.black,
            activeColor: Colors.deepOrange,
            inactiveColor: Colors.white,
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return CategoryScreen(shops: dataServices.allShops);
                    break;
                  case 1:
                    if (dataServices.isUserLoggedIn != null &&
                        dataServices.isUserLoggedIn == true) {
                      return OrderHistoryScreen();
                    } else {
                      return ErrorMessageScreen(
                        flag: 1,
                      );
                    }
                    break;
                  case 2:
                    dataServices.setSelectedDishes();
                    return CartScreen();
                    break;
                  case 3:
                    return SearchScreen();
                    break;
                  case 4:
                    if (dataServices.isUserLoggedIn != null &&
                        dataServices.isUserLoggedIn == true) {
                      return ProfileScreen();
                    } else {
                      return ErrorMessageScreen(
                        flag: 2,
                      );
                    }

                    break;
                  default:
                    return PageOne();
                }
              },
            );
          },
        ),
        onWillPop: _onWillPop,
      );
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Click again to exit", backgroundColor: karkblueish);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class PageOne extends StatefulWidget {
  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
