import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/models/sub_category.dart';
import 'package:finandrib/screens/product_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'cart_screen.dart';

class ProductGroupScreen extends StatefulWidget {
  final int index;
  ProductGroupScreen(this.index);
  @override
  _ProductGroupScreenState createState() => _ProductGroupScreenState();
}

class _ProductGroupScreenState extends State<ProductGroupScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            dataServices.categories[widget.index].name,
            style: kTextStyleAppBarTitle,
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
                        if (dataServices.selectedProducts.length > 0) {
                          Navigator.push(
                            context,
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
        body: Container(
            child: AnimationLimiter(
          child: dataServices.categories[widget.index].subCategories.length > 0
              ? ListView.builder(
                  itemCount: dataServices
                      .categories[widget.index].subCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    SubCategory subCategory = dataServices
                        .categories[widget.index].subCategories[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 1000),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: ScaleAnimation(
                          child: ProductGroupCard(
                            onSelected: () {
                              if (subCategory.availableStocks > 0) {
                                List<Product> products = dataServices
                                    .categories[widget.index]
                                    .subCategories[index]
                                    .products;
                                if (products.length == 1) {
                                  if (dataServices
                                          .categories[widget.index]
                                          .subCategories[index]
                                          .products[0]
                                          .description !=
                                      '') {
                                    dataServices
                                        .categories[widget.index]
                                        .subCategories[index]
                                        .products[0]
                                        .isDescriptionShown = true;
                                  }
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return ProductScreen(
                                      catIndex: widget.index,
                                      subCatIndex: index,
                                    );
                                  }),
                                );
                              }
                            },
                            subCategory: subCategory,
                            onTap: () async {
                              ProgressDialog dialog =
                                  new ProgressDialog(context);
                              dialog.style(message: 'Please wait...');
                              await dialog.show();
                              NetworkResponse response = await NetworkServices
                                  .shared
                                  .notifyOnOutOfStocks(
                                      subCategoryId: subCategory.id);
                              await dialog.hide();
                              _showSnackBar(response.message);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset('images/bagsad.jpeg'),
                  ),
                ),
        )),
      );
    });
  }
}

class ProductGroupCard extends StatelessWidget {
  final Function onSelected;
  final SubCategory subCategory;
  final Function onTap;

  ProductGroupCard({this.onSelected, this.subCategory, this.onTap});

  @override
  Widget build(BuildContext context) {
    double topPadding = (MediaQuery.of(context).size.width - 20) / 2;
    return GestureDetector(
      onTap: onSelected,
      child: Wrap(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // foregroundDecoration: subCategory.availableStocks == 0
                        //     ? BoxDecoration(
                        //         color: Colors.grey,
                        //         backgroundBlendMode: BlendMode.saturation,
                        //       )
                        //     : null,
                        height: (MediaQuery.of(context).size.width - 20) / 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          image: DecorationImage(
                              image: NetworkImage(subCategory.iconImageLink),
                              fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                subCategory.name,
                                style: kTextStyleTitle.copyWith(
                                    color: Colors.deepOrange),
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                subCategory.quantity,
                                style: kTextStyleCardTitle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Visibility(
                                    visible: (subCategory.discountPrice == 0 ||
                                            subCategory.offPercentage() == "0")
                                        ? false
                                        : true,
                                    child: Text(
                                      '$kMoneySymbol ${subCategory.discountPrice.toStringAsFixed(2)}',
                                      style: kTextStyleCalibriBold.copyWith(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationThickness: 2,
                                          decorationColor: Colors.red),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (subCategory.discountPrice == 0 ||
                                            subCategory.offPercentage() == "0")
                                        ? 0
                                        : 10,
                                  ),
                                  Text(
                                    '$kMoneySymbol${subCategory.originalPrice.toStringAsFixed(2)}',
                                    style: kTextStyleCalibriBold.copyWith(
                                        color: Colors.deepOrange, fontSize: 16),
                                  ),
                                ],
                              ),
                              // Text(
                              //   '$kMoneySymbol${subCategory.originalPrice.toStringAsFixed(2)}',
                              //   style: kTextStyleTitle.copyWith(
                              //       color: Colors.deepOrange),
                              // ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: (subCategory.availableStocks < 4 &&
                        subCategory.availableStocks > 0)
                    ? true
                    : false,
                child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 25.0),
                      child: Container(
                        height: 25.0,
                        width: 110.0,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(17),
                              bottomLeft: Radius.circular(17)),
                        ),
                        child: Center(
                            child: Text(
                          'Only ${subCategory.availableStocks} unit(s) left',
                          style: kTextStyleCalibri600.copyWith(
                              color: Colors.white, fontSize: 13),
                        )),
                      ),
                    )),
              ),
              Visibility(
                visible: subCategory.availableStocks == 0 ? true : false,
                child: GestureDetector(
                  onTap: onTap,
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 10.0, top: topPadding - 25),
                        child: Container(
                          height: 25.0,
                          width: 110.0,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                          child: Center(
                              child: Text(
                            'Notify if available',
                            style: kTextStyleCalibri600.copyWith(
                                color: Colors.white, fontSize: 13),
                          )),
                        ),
                      )),
                ),
              ),
              Visibility(
                visible: subCategory.availableStocks == 0 ? true : false,
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: topPadding - 25, right: 10),
                      child: Container(
                        height: 25.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(17),
                              bottomLeft: Radius.circular(17)),
                        ),
                        child: Center(
                            child: Text(
                          'Out of Stocks',
                          style: kTextStyleCalibri600.copyWith(
                              color: Colors.white, fontSize: 13),
                        )),
                      ),
                    )),
              ),
              Visibility(
                visible: (subCategory.discountPrice == 0 ||
                        subCategory.offPercentage() == "0")
                    ? false
                    : true,
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 25.0),
                      child: Container(
                        height: 30.0,
                        width: 75.0,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(17),
                              bottomRight: Radius.circular(17)),
                        ),
                        child: Center(
                            child: Text(
                          '${subCategory.offPercentage()}% Off',
                          style: kTextStyleCalibri600.copyWith(
                              color: Colors.white, fontSize: 16),
                        )),
                      ),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
