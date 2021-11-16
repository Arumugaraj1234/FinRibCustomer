import 'package:finandrib/models/product.dart';
import 'package:finandrib/screens/login_one_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    Provider.of<DataServices>(context, listen: false).setSelectedDishes();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
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
                                            .removeItemInSelectedDishes(index);
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
              visible: dataServices.selectedProducts.length > 0 ? true : false,
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
                                style:
                                    kTextStyleCalibri600.copyWith(fontSize: 16),
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
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) {
                                //       return LoginScreen(2);
                                //     },
                                //   ),
                                // );
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
      );
    });
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
