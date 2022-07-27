import 'package:finandrib/models/product.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker_view/picker_view.dart';
import 'package:flutter_picker_view/picker_view_popup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'cart_screen.dart';
import 'dart:math' as math;

class ProductScreen extends StatefulWidget {
  final int catIndex;
  final int subCatIndex;
  ProductScreen({this.catIndex, this.subCatIndex});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _showPicker(
      {List<String> items,
      BuildContext context,
      DataServices dataService,
      int dishIndex,
      int flag}) {
    PickerController pickerController =
        PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.BottomSheet,
        controller: pickerController,
        context: context,
        title: Text(
          flag == 1 ? 'Cutting Size' : 'Item Size',
          style: kTextStyleCalibriBold.copyWith(fontSize: 16),
        ),
        cancel: Text(
          'cancel',
          style:
              kTextStyleCalibriBold.copyWith(color: Colors.red, fontSize: 16),
        ),
        onCancel: () {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
          style: kTextStyleCalibriBold.copyWith(
              color: Colors.orange, fontSize: 16),
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)];
          if (flag == 1) {
            dataService.setCuttingSize(
                categoryIndex: widget.catIndex,
                subCategoryIndex: widget.subCatIndex,
                productIndex: dishIndex,
                cutSize: selValue);
          } else if (flag == 2) {
            dataService.setProductSize(
                categoryIndex: widget.catIndex,
                subCategoryIndex: widget.subCatIndex,
                productIndex: dishIndex,
                itemSize: selValue);
          }
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row];
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row],
            style: kTextStyleCalibri300.copyWith(fontSize: 16),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            dataServices.categories[widget.catIndex].name,
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: ListView.builder(
                      itemCount: dataServices.categories[widget.catIndex]
                          .subCategories[widget.subCatIndex].products.length,
                      itemBuilder: (context, index) {
                        Product product = dataServices
                            .categories[widget.catIndex]
                            .subCategories[widget.subCatIndex]
                            .products[index];
                        return ProductCard(
                          product: product,
                          onMinusTapped: () {
                            if (product.count > 0) {
                              dataServices.reduceItem(
                                  categoryIndex: widget.catIndex,
                                  subCategoryIndex: widget.subCatIndex,
                                  productIndex: index);
                              Fluttertoast.showToast(
                                  msg: '${product.name} got removed to cart',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                          },
                          onPlusTapped: () {
                            if (product.count < product.availableStocks) {
                              dataServices.increaseItem(
                                  categoryIndex: widget.catIndex,
                                  subCategoryIndex: widget.subCatIndex,
                                  productIndex: index);
                              Fluttertoast.showToast(
                                  msg: '${product.name} got added to cart',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                          },
                          onItemSizeTapped: () {
                            _showPicker(
                                items: product.itemSizeOptions,
                                context: context,
                                dataService: dataServices,
                                dishIndex: index,
                                flag: 2);
                          },
                          onCuttingSizeTapped: () {
                            _showPicker(
                                items: product.cuttingSizeOptions,
                                context: context,
                                dataService: dataServices,
                                dishIndex: index,
                                flag: 1);
                          },
                          setDescriptionStatus: () {
                            dataServices.setDescriptionStatusOfProduct(
                                categoryIndex: widget.catIndex,
                                subCategoryIndex: widget.subCatIndex,
                                productIndex: index);
                          },
                        );
                      }),
                ),
              ),
              InkWell(
                onTap: () {
                  dataServices.setSelectedDishes();
                  if (dataServices.selectedProducts.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CartScreen();
                      }),
                    );
                  } else {
                    final snackBar = new SnackBar(
                        content: new Text("Your cart is empty"),
                        backgroundColor: Colors.red);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Container(
                  height: 40,
                  color: Colors.deepOrange,
                  child: Center(
                    child: Text(
                      "View Cart",
                      style: kTextStyleCalibriBold.copyWith(
                          color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            '$kMoneySymbol${dataServices.selectedProductsTotalPrice.toStringAsFixed(2)}',
                            style: kTextStyleCalibri600.copyWith(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: Container(
                    //     color: Colors.deepOrange,
                    //     child: Text('data'),
                    //   ),
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Function onPlusTapped;
  final Function onMinusTapped;
  final Function onItemSizeTapped;
  final Function onCuttingSizeTapped;
  final Function setDescriptionStatus;

  ProductCard(
      {this.product,
      this.onPlusTapped,
      this.onMinusTapped,
      this.onItemSizeTapped,
      this.onCuttingSizeTapped,
      this.setDescriptionStatus});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 10, left: 10, top: 15, bottom: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset(0, 0),
                    )
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.width - 0) / 2, //20
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(product.imageLink),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: kTextStyleCalibriBold.copyWith(
                                color: Colors.deepOrange, fontSize: 18),
                          ),
                          Text(
                            product.qtyDescription,
                            style: kTextStyleCalibri300.copyWith(
                                color: Colors.black, fontSize: 18),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Visibility(
                                      visible: (product.cutOffPrice == 0 ||
                                              product.offPercentage() == "0")
                                          ? false
                                          : true,
                                      child: Text(
                                        '$kMoneySymbol ${product.cutOffPrice.toStringAsFixed(2)}',
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
                                      width: (product.cutOffPrice == 0 ||
                                              product.offPercentage() == "0")
                                          ? 0
                                          : 10,
                                    ),
                                    Text(
                                      '$kMoneySymbol${product.price.toStringAsFixed(2)}',
                                      style: kTextStyleCalibriBold.copyWith(
                                          color: Colors.deepOrange,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 120,
                                child: Center(
                                  child: Container(
                                    height: 35,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: onMinusTapped,
                                            child: Container(
                                              child: Center(
                                                child: Text(
                                                  '  -',
                                                  style: kTextStyleCalibriBold
                                                      .copyWith(fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        VerticalDivider(
                                          thickness: 2,
                                          color: Colors.black,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                product.count.toString(),
                                                style: kTextStyleCalibriBold
                                                    .copyWith(fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                        VerticalDivider(
                                          thickness: 2,
                                          color: Colors.black,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: onPlusTapped,
                                            child: Container(
                                              child: Center(
                                                child: Text(
                                                  '+  ',
                                                  style: kTextStyleCalibriBold
                                                      .copyWith(fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: (product.isCuttingOptionsAvailable ==
                                        false &&
                                    product.isItemSizeOptionsAvailable == false)
                                ? 0
                                : 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Visibility(
                                          visible: product
                                              .isItemSizeOptionsAvailable,
                                          child: GestureDetector(
                                            onTap: onItemSizeTapped,
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  )),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    product.itemSize == ''
                                                        ? '  Item Size'
                                                        : product.itemSize,
                                                    style: kTextStyleCalibriBold
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.white,
                                                    size: 30,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(),
                                        )
                                      ],
                                    ),
                                  )),
                              Expanded(child: Container()),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Visibility(
                                          visible:
                                              product.isCuttingOptionsAvailable,
                                          child: GestureDetector(
                                            onTap: onCuttingSizeTapped,
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  )),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    product.cuttingSize == ''
                                                        ? '  Cutting Size'
                                                        : product.cuttingSize,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    style: kTextStyleCalibriBold
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.white,
                                                    size: 30,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: product.isDescriptionShown ? 10 : 0,
                          ),
                          Visibility(
                            visible: product.isDescriptionShown,
                            child: Text(
                              product.isDescriptionShown
                                  ? product.description
                                  : '',
                              style:
                                  kTextStyleCalibri300.copyWith(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: product.isDescriptionShown ? 0 : 0,
                          ),
                          GestureDetector(
                            onTap: setDescriptionStatus,
                            child: Center(
                              child: Center(
                                child: Transform.rotate(
                                  angle:
                                      (product.isDescriptionShown ? 270 : 90) *
                                          math.pi /
                                          180,
                                  child: Icon(
                                    Icons.double_arrow,
                                    size: 25,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          )

                          /*Icon(
                            product.isDescriptionShown
                                ? Icons.double_arrow
                                : Icons.double_arrow,
                            size: 25,
                            color: Colors.deepOrange,
                          )*/

                          // Icons.arrow_drop_up
                          //     : Icons.arrow_drop_down,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: product.availableStocks < 4 ? true : false,
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
                        product.availableStocks > 0
                            ? 'Only ${product.availableStocks} unit(s) left.'
                            : 'Out of Stocks',
                        style: kTextStyleCalibri600.copyWith(
                            color: Colors.white, fontSize: 13),
                      )),
                    ),
                  )),
            ),
            Visibility(
              visible:
                  (product.cutOffPrice == 0 || product.offPercentage() == "0")
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
                        '${product.offPercentage()}% Off',
                        style: kTextStyleCalibri600.copyWith(
                            color: Colors.white, fontSize: 16),
                      )),
                    ),
                  )),
            )
          ],
        )
      ],
    );
  }
}
