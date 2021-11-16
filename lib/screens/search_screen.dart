import 'package:finandrib/models/product.dart';
import 'package:finandrib/screens/product_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker_view/picker_view.dart';
import 'package:flutter_picker_view/picker_view_popup.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text(
          'Search',
          style: kTextStyleAppBarTitle,
        ),
        actions: [searchBar.getSearchAction(context)]);
  }

  _SearchScreenState() {
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: print,
        onChanged: (String value) {
          Provider.of<DataServices>(context, listen: false)
              .filterProducts(value);
        },
        onCleared: () {
          Provider.of<DataServices>(context, listen: false).filterProducts('');
        },
        buildDefaultAppBar: buildAppBar);
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
            dataService.setCuttingSizeOfFilteredProducts(
                index: dishIndex, cutSize: selValue);
          } else if (flag == 2) {
            dataService.setProductSizeOfFilteredProducts(
                index: dishIndex, itemSize: selValue);
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
        appBar: searchBar.build(context),
        body: Container(
          child: ListView.builder(
              itemCount: dataServices.filteredProducts.length,
              itemBuilder: (context, index) {
                Product product = dataServices.filteredProducts[index];
                return ProductCard(
                  product: product,
                  onPlusTapped: () {
                    if (product.count < product.availableStocks) {
                      dataServices.increaseItemOfFilteredProducts(index: index);
                    }
                  },
                  onMinusTapped: () {
                    if (product.count > 0) {
                      dataServices.reduceItemOfFilteredProducts(index: index);
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
                    dataServices.setDescriptionStatusForFilterProducts(
                        product: product, index: index);
                  },
                );
              }),
        ),
      );
    });
  }
}
