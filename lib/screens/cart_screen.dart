import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/screens/login_one_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:finandrib/screens/login_screen.dart';
import 'package:finandrib/screens/address_select_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataServices>(context, listen: false).setSelectedDishes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return WillPopScope(
        onWillPop: () async {
          dataServices.removeSelectedOfferProduct();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            title: Text(
              'My Cart',
              style: kTextStyleAppBarTitle,
            ),
          ),
          body: Container(
              child: Column(
            children: [
              Expanded(
                child: dataServices.selectedProducts.length > 0
                    ? Container(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            itemCount: dataServices.selectedProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1000),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: CartItemCard(
                                      product:
                                          dataServices.selectedProducts[index],
                                      onMinusPressed: () {
                                        if (dataServices
                                                .selectedProducts[index].count >
                                            1) {
                                          dataServices
                                              .removeItemInSelectedDishes(
                                                  index);
                                        }
                                      },
                                      onPlusPressed: () {
                                        dataServices
                                            .addItemInSelectedDishes(index);
                                      },
                                      onRemovePressed: () {
                                        dataServices
                                            .removeItemInSelectedItems(index);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Container(
                        child: Center(
                          child: Image.asset('images/cart_empty.png'),
                        ),
                      ),
              ),
              Visibility(
                visible:
                    dataServices.selectedProducts.length > 0 ? true : false,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 4,
                      offset: Offset(0, 0),
                    )
                  ]),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total',
                                  style: kTextStyleCalibri600.copyWith(
                                      fontSize: 16),
                                ),
                              ),
                              Text(
                                '$kMoneySymbol${dataServices.selectedProductsTotalPrice.toStringAsFixed(2)}',
                                style: kTextStyleCalibriBold.copyWith(
                                    color: Colors.deepOrange, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: MaterialButton(
                            onPressed: () async {
                              if (dataServices.selectedProducts.length > 0) {
                                double selectedDishesAmount = 0;
                                dataServices.selectedProductsTotalPrice;
                                List<Product> selectedProducts =
                                    dataServices.selectedProducts;
                                List<int> selectedProductsId = [];

                                if (dataServices.isWithOffer == 0) {
                                  /// If with offer is 0
                                  for (Product p in selectedProducts) {
                                    if (p.cutOffPrice == 0 ||
                                        p.offPercentage() == "0") {
                                      selectedProductsId.add(p.id);
                                      selectedDishesAmount =
                                          selectedDishesAmount + p.totalPrice;
                                    } else {
                                      /// if product has price cut off should not get added for getting offer
                                    }
                                  }
                                } else {
                                  /// if with offer is 1
                                  for (Product p in selectedProducts) {
                                    selectedProductsId.add(p.id);
                                  }
                                  selectedDishesAmount =
                                      dataServices.selectedProductsTotalPrice;
                                }

                                dataServices.removeSelectedOfferProduct();
                                ProgressDialog dialog =
                                    new ProgressDialog(context);
                                dialog.style(message: 'Please wait...');
                                await dialog.show();
                                NetworkResponse response =
                                    await NetworkServices.shared.getOffers(
                                        amount: selectedDishesAmount,
                                        dishes: selectedProductsId,
                                        context: context);
                                await dialog.hide();

                                if (response.code == 1) {
                                  List<Product> offerProducts = response.data;

                                  if (offerProducts.length > 0) {
                                    showDialog(
                                        context: context,
                                        builder: (cxt) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 50, vertical: 50),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.white54,
                                                        offset: Offset(0, 0),
                                                        blurRadius: 5,
                                                        spreadRadius: 2),
                                                    BoxShadow(
                                                        color: Colors
                                                            .orange.shade400,
                                                        offset: Offset(0, 0),
                                                        blurRadius: 5,
                                                        spreadRadius: 2)
                                                  ]),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "OFFERS",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        decoration:
                                                            TextDecoration
                                                                .none),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Expanded(
                                                    child: ListView.builder(
                                                        itemCount: offerProducts
                                                            .length,
                                                        itemBuilder:
                                                            (cxt, index) {
                                                          Product product =
                                                              offerProducts[
                                                                  index];
                                                          return OfferProductWidget(
                                                              product, () {
                                                            product.count = 1;
                                                            dataServices
                                                                .addOfferItemToSelectedDishes(
                                                                    product);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _goToNextScreen(
                                                                dataServices);
                                                          });
                                                        }),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _goToNextScreen(
                                                            dataServices);
                                                      },
                                                      child: Text("SKIP")),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  } else {
                                    _goToNextScreen(dataServices);
                                  }
                                } else {
                                  _goToNextScreen(dataServices);
                                }
                              }
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 3,
                                          spreadRadius: 2,
                                          offset: Offset(0, 0),
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      'PROCEED',
                                      style: kTextStyleCalibriBold.copyWith(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
        ),
      );
    });
  }

  _goToNextScreen(DataServices dataServices) {
    if (dataServices.isUserLoggedIn != null &&
        dataServices.isUserLoggedIn == true) {
      dataServices.calculateGst();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) {
          return AddressSelectScreen(
            shopId: dataServices.selectedShop.id,
          );
        }),
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen(2);
            // return LoginOneScreen(
            //   fromScreen: 2,
            // );
          },
        ),
      );
    }
  }
}

class OfferProductWidget extends StatelessWidget {
  final Product product;
  final Function onSelected;

  OfferProductWidget(this.product, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
          child: Container(
            height: 125,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade400,
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  spreadRadius: 2)
            ]),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(product.imageLink),
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        product.qtyDescription,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(kMoneySymbol + product.price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              decoration: TextDecoration.none))
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Product product;
  final Function onMinusPressed;
  final Function onPlusPressed;
  final Function onRemovePressed;

  CartItemCard(
      {this.product,
      this.onMinusPressed,
      this.onPlusPressed,
      this.onRemovePressed});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
              child: Stack(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(product.thumbNail),
                                fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: kTextStyleCalibri600.copyWith(
                                      color: Colors.deepOrange, fontSize: 16),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'QTY: (${product.productGrams().toStringAsFixed(0)} ${product.initialUom()}) ${product.count} x $kMoneySymbol${product.price}',
                                  style: kTextStyleCalibri300.copyWith(
                                      fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.orange,
                                          size: 25,
                                        ),
                                        onPressed: onMinusPressed),
                                    Text(
                                      product.count.toString(),
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.orange,
                                          size: 25,
                                        ),
                                        onPressed: onPlusPressed),
                                    Text(
                                      '${product.unitOfMeasurement() == "Grams" ? product.totalGrams().toStringAsFixed(0) : product.totalGrams().toStringAsFixed(3)} ${product.unitOfMeasurement()}',
                                      style: kTextStyleCalibri300.copyWith(
                                          fontSize: 16),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$kMoneySymbol${product.totalPrice.toStringAsFixed(2)}',
                          style: kTextStyleCalibriBold.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: onRemovePressed,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider()
          ],
        )
      ],
    );
  }
}
