import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:finandrib/models/category.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/quality.dart';
import 'package:finandrib/models/shop.dart';
import 'package:finandrib/screens/cart_screen.dart';
import 'package:finandrib/screens/main_drawer.dart';
import 'package:finandrib/screens/order_track_screen.dart';
import 'package:finandrib/screens/product_group_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:finandrib/customized_widgets/custom_tf_one.dart';

class CategoryScreen extends StatefulWidget {
  final List<Shop> shops;
  CategoryScreen({this.shops});
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Quality> _qualities = [
    Quality(
        icon: 'https://www.finandrib.com/Images/icons/1.png',
        name: 'Delivery Within 2 Hours'),
    Quality(
        icon: 'https://www.finandrib.com/Images/icons/3.png',
        name: 'No Preservatives'),
    Quality(
        icon: 'https://www.finandrib.com/Images/icons/5.png',
        name: 'Antibiotic free'),
    Quality(
        icon: 'https://www.finandrib.com/Images/icons/4.png',
        name: 'No Chemicals'),
    Quality(
        icon: 'https://www.finandrib.com/Images/icons/2.png',
        name: 'Halal Certification')
  ];

  List<String> _headerImages = [
    'https://www.finandrib.com/Images/banner1.png',
    'https://www.finandrib.com/Images/banner2.png',
    'https://www.finandrib.com/Images/banner3.png',
    'https://www.finandrib.com/Images/banner4.png',
    'https://www.finandrib.com/Images/banner5.png',
    'https://www.finandrib.com/Images/banner6.png'
  ];

  ScrollController _scrollController = new ScrollController(
    // NEW
    initialScrollOffset: 0.0, // NEW
    keepScrollOffset: true, // NEW
  );

  BuildContext _ctx;
  String _areaPinCode = '';
  bool _shopAvailableStatus = false;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg');
  Timer _timerToCheckForActiveOrders;
  Timer _timerToRefreshProducts;
  bool _pinCodeChangeViewToShow = false;
  TextEditingController _pinCodeTC = new TextEditingController();
  FocusNode _pinCodeFN = new FocusNode();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _startTimerToCheckForActiveOrders() {
    const tenMin = const Duration(minutes: 5);
    _timerToCheckForActiveOrders = new Timer.periodic(
      tenMin,
      (Timer timer) {
        _getActiveOrdersInLoop();
      },
    );
  }

  void _getActiveOrdersInLoop() async {
    print("getting active orders");
    NetworkResponse response =
        await NetworkServices.shared.getLiveOrders(context: context);
  }

  _refreshProductsInLoop() async {
    print('Products getting refresh');
    Shop shop = Provider.of<DataServices>(context, listen: false).selectedShop;
    await NetworkServices.shared
        .getProductByShop(context: context, shopId: shop.id);
  }

  void _startTimerToRefreshProducts() {
    const duration = const Duration(minutes: 1);
    _timerToRefreshProducts = new Timer.periodic(
      duration,
      (Timer timer) {
        _refreshProductsInLoop();
      },
    );
  }

  void _init() {
    _getAllShops();
  }

  void _getAllShops() async {
    NetworkResponse response =
        await NetworkServices.shared.getAllShops(context: context);
  }

  void _getUserLocation() async {
    // Provider.of<DataServices>(context, listen: false).setSelectedShop(0);
    // //Provider.of<DataServices>(context, listen: false).setShopsFlagRemarks();
    // await NetworkServices.shared
    //     .getProductByShop(context: context, shopId: widget.shops[0].id);

    /*var geoLocator = Geolocator();
    var status = await geoLocator.checkGeolocationPermissionStatus();
    print('Location Status: $status');
    var enableStatus = await geoLocator.isLocationServiceEnabled();
    print('Enable Status: $enableStatus');
    geoLocator.forceAndroidLocationManager = true;
    Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude);
    List<Placemark> placemark = await geoLocator.placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark placeA = placemark[0];

    String subLocality = placeA.subLocality == '' ? '' : placeA.subLocality;
    String subAdministrativeArea =
        placeA.subAdministrativeArea == '' ? '' : placeA.subAdministrativeArea;
    String postal = placeA.postalCode;

    print(placeA.toJson());

    setState(() {
      _areaPinCode = postal;
      // _areaName = subLocality == '' ? subAdministrativeArea : subLocality;
    });
    //String postal = '627808';
    List<Shop> shops = widget.shops;
    int flag = 0;
    bool isShopAvailable = false;
    for (var shop in shops) {
      for (var pin in shop.pinCodes) {
        if (postal == pin) {
          isShopAvailable = true;
          break;
        }
      }
      if (isShopAvailable == true) {
        break;
      }
      flag++;
    }
    if (_timerToRefreshProducts != null) {
      _timerToRefreshProducts.cancel();
    }

    if (isShopAvailable) {
      Provider.of<DataServices>(context, listen: false).setSelectedShop(flag);
      await NetworkServices.shared
          .getProductByShop(context: context, shopId: widget.shops[flag].id);
      setState(() {
        _shopAvailableStatus = false;
      });
      _startTimerToRefreshProducts();
    } else {
      Provider.of<DataServices>(context, listen: false).setSelectedShop(0);
      //Provider.of<DataServices>(context, listen: false).setShopsFlagRemarks();
      await NetworkServices.shared
          .getProductByShop(context: context, shopId: widget.shops[0].id);
      setState(() {
        _shopAvailableStatus = false;
      });
      _startTimerToRefreshProducts();
    }*/

    Provider.of<DataServices>(context, listen: false).setSelectedShop(0);
    //Provider.of<DataServices>(context, listen: false).setShopsFlagRemarks();
    NetworkResponse response = await NetworkServices.shared
        .getProductByShop(context: context, shopId: widget.shops[0].id);

    if (response.code == 1) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          // NEW
          _scrollController.position.maxScrollExtent, // NEW
          duration: const Duration(milliseconds: 10000), // NEW
          curve: Curves.ease, // NEW
        );
      } else {
        print("gfmfk ggkg fgkgj");
      }
    }

    setState(() {
      _shopAvailableStatus = false;
    });
    _startTimerToRefreshProducts();
  }

  Widget _progressGroupLayout() {
    double width = MediaQuery.of(context).size.width;
    double shimmerWidth = width * 0.5;
    Color baseColor = Colors.grey[300];
    Color highLightColor = Colors.grey[100];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highLightColor,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(
                    width: ((MediaQuery.of(context).size.width - 60) / 2),
                    height: ((MediaQuery.of(context).size.width - 60) / 2)),
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 30.0),
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highLightColor,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(
                    width: ((MediaQuery.of(context).size.width - 60) / 2),
                    height: ((MediaQuery.of(context).size.width - 60) / 2)),
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  void _getShopByPinCode({String pinCode, DataServices dS}) async {
    setState(() {
      _areaPinCode = pinCode;
      //_areaName = subLocalArea == '' ? subAdminArea : subLocalArea;
    });

    List<Shop> shops = dS.allShops;
    int flag = 0;
    bool isShopAvailable = false;
    for (var shop in shops) {
      bool isAvailable = shop.pinCodes.contains(pinCode);
      if (isAvailable) {
        isShopAvailable = true;
        break;
      }
      flag++;
    }

    if (_timerToRefreshProducts != null) {
      _timerToRefreshProducts.cancel();
    }

    if (isShopAvailable) {
      Provider.of<DataServices>(context, listen: false).setSelectedShop(flag);
      await NetworkServices.shared
          .getProductByShop(context: context, shopId: widget.shops[flag].id);
      _startTimerToRefreshProducts();
    } else {
      Provider.of<DataServices>(context, listen: false).setSelectedShop(0);
      //Provider.of<DataServices>(context, listen: false).setShopsFlagRemarks();
      await NetworkServices.shared
          .getProductByShop(context: context, shopId: widget.shops[0].id);
      _startTimerToRefreshProducts();
    }
  }

  void displayPrediction(Prediction p, DataServices dS) async {
    Provider.of<DataServices>(context, listen: false).setCategories([]);
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);
      String postal = address[0].toMap()['postalCode'] ?? '';
      String subAdminArea = address[0].toMap()['subAdministrativeArea'] ?? '';
      String subLocalArea = address[0].toMap()['subLocality'] ?? '';

      setState(() {
        _areaPinCode = postal;
        //_areaName = subLocalArea == '' ? subAdminArea : subLocalArea;
      });

      List<Shop> shops = dS.allShops;
      int flag = 0;
      bool isShopAvailable = false;
      for (var shop in shops) {
        bool isAvailable = shop.pinCodes.contains(postal);
        if (isAvailable) {
          isShopAvailable = true;
          break;
        }
        flag++;
      }

      if (isShopAvailable) {
        Provider.of<DataServices>(context, listen: false).setSelectedShop(flag);
        await NetworkServices.shared
            .getProductByShop(context: context, shopId: widget.shops[flag].id);
      } else {
        Provider.of<DataServices>(context, listen: false).setSelectedShop(0);
        //Provider.of<DataServices>(context, listen: false).setShopsFlagRemarks();
        await NetworkServices.shared
            .getProductByShop(context: context, shopId: widget.shops[0].id);
      }
    }
  }

  StreamController _isGridViewBuilded = StreamController<int>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserLocation();
      _getActiveOrdersInLoop();
      _startTimerToCheckForActiveOrders();
      print('Category Init State');

      /*_isGridViewBuilded.stream.listen((flag) {
        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
          int length = Provider.of<DataServices>(context, listen: false)
              .categories
              .length;

          if (flag == length) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _scrollController.addListener(() {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    // NEW
                    _scrollController.position.maxScrollExtent, // NEW
                    duration: const Duration(milliseconds: 10000), // NEW
                    curve: Curves.ease, // NEW
                  );
                }
              });
            });
          }
        });
      });*/
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerToCheckForActiveOrders.cancel();
    _pinCodeFN.dispose();
    _pinCodeTC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark));
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: MainDrawer(
          isLoggedIn: dataServices.isUserLoggedIn ?? false,
          services: dataServices,
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            leading: Builder(builder: (context) {
              return Transform.translate(
                offset: Offset(0.0, -5.0),
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              );
            }),
            backgroundColor: Colors.deepOrange,
            title: Text(
              'Fin & Rib',
              style: kTextStyleAppBarTitle,
              textAlign: TextAlign.center,
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      IconButton(
                        icon: new Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Provider.of<DataServices>(context, listen: false)
                              .setSelectedDishes();
                          print(dataServices.selectedProducts.length);
                          if (dataServices.selectedProducts.length > 0) {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(builder: (context) {
                                return CartScreen();
                              }),
                            );
                          }
                        },
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          height: 24.0,
                          width: 24.0,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 5,
                            minHeight: 5,
                          ),
                          child: Text(
                            dataServices.selectedItemCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
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
        body: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  /*Container(
                    height: 25,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 25,
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              'Your PinCode : $_areaPinCode',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Calibri',
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 12,
                              ),
                              onPressed: () async {
                                setState(() {
                                  _pinCodeChangeViewToShow = true;
                                });
                                /*Prediction prediction =
                                    await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey:
                                            "AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg",
                                        components: [
                                      Component(Component.country, "IN")
                                    ]);
                                print(prediction.description);
                                displayPrediction(prediction, dataServices);*/
                              }),
                        )
                      ],
                    ),
                  ),*/
                  Container(
                    height: 190, //MediaQuery.of(context).size.height / 4
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(
                      horizontal: 0,
                    ),
                    child: CarouselSlider(
                      options: CarouselOptions(
                          autoPlay: true, reverse: true, viewportFraction: 1.0),
                      items: _headerImages
                          .map(
                            (item) => Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                image: DecorationImage(
                                    image: NetworkImage(item),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Container(
                    height: 70,
                    child: AnimationLimiter(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _qualities.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1000),
                              child: SlideAnimation(
                                horizontalOffset: 60.0,
                                child: FadeInAnimation(
                                  child:
                                      QualityCard(quality: _qualities[index]),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Shop By Category',
                                  style: kTextStyleTitle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  child: dataServices.categories.length == 0
                                      ? ListView.builder(
                                          itemBuilder: (context, index) {
                                            return _progressGroupLayout();
                                          },
                                          itemCount: 5,
                                        )
                                      : GridView.count(
                                          crossAxisCount: 2,
                                          scrollDirection: Axis.vertical,
                                          controller: _scrollController,
                                          //primary: false,
                                          childAspectRatio: 1.1,
                                          children: List.generate(
                                            dataServices.categories.length,
                                            (int index) {
                                              _isGridViewBuilded.add(index + 1);
                                              return CategoryCard(
                                                onSelected: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                      return ProductGroupScreen(
                                                          index);
                                                    }),
                                                  );
                                                },
                                                category: dataServices
                                                    .categories[index],
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: _shopAvailableStatus,
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                        Visibility(
                          visible: dataServices.selectedShop.flag == 1
                              ? false
                              : true,
                          child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                            'images/closed.png',
                                          ),
                                          fit: BoxFit.fill)),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    dataServices.selectedShop.remarks,
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        shadows: [
                                          Shadow(
                                              color: Colors.grey,
                                              offset: Offset(2, 5),
                                              blurRadius: 5.0)
                                        ],
                                        color: Colors.black54,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: dataServices.activeOrders.length > 0 ? true : false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (context) {
                            return OrderTrackScreen(
                              order: dataServices.activeOrders[0],
                              index: 0,
                            );
                          }),
                        );
                      },
                      child: Wrap(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(3, 3),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dataServices.activeOrders.length > 0
                                              ? dataServices
                                                  .activeOrders[0].orderDate
                                              : '',
                                          style: kTextStyleCalibri300.copyWith(
                                              fontSize: 15),
                                        ),
                                      ),
                                      Text(
                                        '#${dataServices.activeOrders.length > 0 ? dataServices.activeOrders[0].orderId : ''}',
                                        style: kTextStyleCalibriBold.copyWith(
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
                                  Text(
                                    dataServices.activeOrders.length > 0
                                        ? (dataServices.activeOrders[0]
                                                    .deliverySlotId ==
                                                0
                                            ? 'Express Delivery - ${dataServices.activeOrders[0].deliveryTime}'
                                            : 'Scheduled Delivery - ${dataServices.activeOrders[0].scheduledDeliveryTime}')
                                        : '',
                                    style: kTextStyleCalibri300.copyWith(
                                        fontSize: 15),
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
                                          dataServices.activeOrders.length > 0
                                              ? dataServices.activeOrders[0]
                                                  .deliveryAddress
                                              : '',
                                          style: kTextStyleCalibri300.copyWith(
                                              fontSize: 15),
                                        ),
                                      )
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        style: kTextStyleCalibri300.copyWith(
                                            fontSize: 15, color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: 'Status: ',
                                          ),
                                          TextSpan(
                                            text: dataServices
                                                        .activeOrders.length >
                                                    0
                                                ? dataServices.activeOrders[0]
                                                    .orderStatusDesc
                                                : '',
                                            style:
                                                kTextStyleCalibriBold.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 15),
                                          )
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      dataServices.setActiveOrders([]);
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 25,
                    ),
                  )
                ]),
              ),
            ),
            Visibility(
              visible: dataServices.isAdvImgToShow &&
                  dataServices.selectedShop.isAdvImageToShow,
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: MediaQuery.of(context).size.width * 0.55,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                                image: NetworkImage(
                                    dataServices.selectedShop.advImageUrl ??
                                        ''),
                                fit: BoxFit.fill),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              dataServices.setAdvertisementImageStatus(false);
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _pinCodeChangeViewToShow,
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: MediaQuery.of(context).size.width * 0.55,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Please enter your area pincode below',
                                style: kTextStyleCalibriBold.copyWith(
                                    fontSize: 16),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: CustomTFOne(
                                  controller: _pinCodeTC,
                                  focusNode: _pinCodeFN,
                                  labelText: 'Pincode',
                                  inputType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  inputAction: TextInputAction.done,
                                  capitalization: TextCapitalization.words,
                                  onSubmitted: (value) {
                                    FocusScope.of(context).requestFocus(
                                      new FocusNode(),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(
                                    new FocusNode(),
                                  );
                                  String pc = _pinCodeTC.text;
                                  var a = pc.replaceAll(RegExp(r"[^\s\w]"), "");
                                  var b = a.replaceAll(" ", "");
                                  _pinCodeTC.text = b;
                                  if (b.length == 6) {
                                    setState(() {
                                      _pinCodeChangeViewToShow = false;
                                    });
                                    _getShopByPinCode(
                                        pinCode: pc, dS: dataServices);
                                  } else {
                                    _showSnackBar(
                                        'Please provide a valid pincode');
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'OK',
                                      style: kTextStyleCalibriBold.copyWith(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pinCodeChangeViewToShow = false;
                              });
                              dataServices.setAdvertisementImageStatus(false);
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class CategoryCard extends StatelessWidget {
  final Function onSelected;
  final Category category;

  CategoryCard({this.onSelected, this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
          child: Stack(
            children: [
              SizedBox(
                height: ((MediaQuery.of(context).size.width - 100) / 2),
                width: (MediaQuery.of(context).size.width - 100) / 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 0),
                      )
                    ]),
                  ),
                ),
              ),
              Container(
                  height: ((MediaQuery.of(context).size.width - 100) / 2),
                  width: (MediaQuery.of(context).size.width - 100) / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Container(
                    height: ((MediaQuery.of(context).size.width - 100) / 2),
                    width: (MediaQuery.of(context).size.width - 100) / 2,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                              ),
                              image: DecorationImage(
                                  image: NetworkImage(category.image),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category.name,
                                style: kTextStyleCardTitle,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          )),
    );
  }
}

/*Stack(
children: [
Container(
height: ((MediaQuery.of(context).size.width - 90) / 2),
width: (MediaQuery.of(context).size.width - 90) / 2,
child: Column(
children: [
Expanded(
flex: 4,
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.only(
topRight: Radius.circular(15),
topLeft: Radius.circular(15),
),
image: DecorationImage(
image: NetworkImage(category.image),
fit: BoxFit.cover),
),
),
),
Container(
height: 1,
color: Colors.grey,
),
Expanded(
flex: 1,
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(15),
bottomRight: Radius.circular(15),
),
),
child: Center(
child: Text(
category.name,
style: kTextStyleCardTitle,
),
),
),
)
],
),
),
// Align(
//   alignment: Alignment.bottomCenter,
//   child: Container(
//     width: (((MediaQuery.of(context).size.width - 90) / 2) * 0.7),
//     height: 0,
//     decoration: BoxDecoration(boxShadow: [
//       BoxShadow(
//         color: Colors.black87,
//         blurRadius: 5,
//         spreadRadius: 1,
//         offset: Offset(0, 0),
//       )
//     ]),
//   ),
// ),
],
),*/

class QualityCard extends StatelessWidget {
  final Quality quality;

  QualityCard({@required this.quality});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      child: Container(
        height: 64.0,
        width: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(quality.icon),
                        fit: BoxFit.fitHeight),
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  quality.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Calibri',
                      fontSize: 5,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ((MediaQuery.of(context).size.width - 60) / 2),
      width: (MediaQuery.of(context).size.width - 60) / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
    );
  }
}

/*AnimationLimiter(
child: GridView.count(
crossAxisCount: 2,
primary: false,
childAspectRatio: 1.1,
children: List.generate(
dataServices.categories.length,
(int index) {
return AnimationConfiguration
    .staggeredGrid(
position: index,
duration: const Duration(
milliseconds: 1000),
columnCount: 5,
child: ScaleAnimation(
child: SlideAnimation(
child: CategoryCard(
onSelected: () {
Navigator.of(context,
rootNavigator:
true)
    .push(
MaterialPageRoute(
builder:
(context) {
return ProductGroupScreen(
index);
}),
);
},
category: dataServices
    .categories[index],
),
),
),
);
},
),
),
)*/
