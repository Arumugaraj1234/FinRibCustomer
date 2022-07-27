import 'package:finandrib/models/address.dart';
import 'package:finandrib/models/banner.dart';
import 'package:finandrib/models/category.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/models/promo_offer.dart';
import 'package:finandrib/models/shop.dart';
import 'package:finandrib/models/sub_category.dart';
import 'package:finandrib/screens/delivery_type_screen.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/cupertino.dart';

class DataServices extends ChangeNotifier {
  bool _isUserLoggedIn;
  bool get isUserLoggedIn => _isUserLoggedIn;
  void setUserLoggedInStatus(bool newValue) {
    _isUserLoggedIn = newValue;
    notifyListeners();
  }

  int _userId;
  int get userId => _userId;
  void setUserId(int newValue) {
    _userId = newValue;
    notifyListeners();
  }

  Map<String, String> _userDetails;
  Map<String, String> get userDetails => _userDetails;
  void setUserDetails(Map<String, String> newValue) {
    _userDetails = newValue;
    print('Got Stored: $newValue');
    notifyListeners();
  }

  String _googleApiKey = '';
  String get googleApiKey => _googleApiKey;
  String _razorPayKey = '';
  String get razorPayKey => _razorPayKey;
  int _isWithOffer = 0;
  int get isWithOffer => _isWithOffer;
  void setGoogleAndRazorPayKeys(
      {String googleApiKey, String razorPayKey, int isWithOffer}) {
    _googleApiKey = googleApiKey;
    _razorPayKey = razorPayKey;
    _isWithOffer = isWithOffer;
    print(_googleApiKey);
    print(_razorPayKey);
    notifyListeners();
  }

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;
  setBannersData(List<BannerModel> value) {
    _banners = value;
    notifyListeners();
  }

  String _fcmToken = '';
  String get fcmToken => _fcmToken;
  void setFcmToken(String token) {
    _fcmToken = token;
    print(_fcmToken);
    notifyListeners();
  }

  List<Shop> _allShops = [];
  List<Shop> get allShops => _allShops;
  void setAllShops(List<Shop> value) {
    value.forEach((element) {
      print(element.toJson());
    });
    _allShops = value;
    _selectedShop = value[0];
    notifyListeners();
  }

  Shop _selectedShop;
  Shop get selectedShop => _selectedShop;
  void setSelectedShop(int index) {
    _selectedShop = _allShops[index];
    notifyListeners();
  }

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  void setCategories(List<Category> newValue) {
    setSelectedDishes();
    print(_selectedProducts);
    List<Category> cat = newValue;
    for (Category c in cat) {
      for (SubCategory sC in c.subCategories) {
        for (Product p in sC.products) {
          for (Product sP in _selectedProducts) {
            if (p.id == sP.id) {
              if (sP.count <= p.availableStocks) {
                p.count = sP.count;
              }
            }
          }
        }
      }
    }
    _categories = cat;

    for (Category c in _categories) {
      for (SubCategory sC in c.subCategories) {
        for (Product p in sC.products) {
          if (p.count > 0) {
            print(p.name);
          }
        }
      }
    }
    //_selectedItemCount = 0;
    setSelectedDishes();
    print(newValue);
    notifyListeners();
  }

  int _selectedItemCount = 0;
  int get selectedItemCount => _selectedItemCount;

  double _selectedProductsTotalPrice = 0.0;
  double get selectedProductsTotalPrice => _selectedProductsTotalPrice;

  void setDescriptionStatusOfProduct(
      {int categoryIndex, int subCategoryIndex, int productIndex}) {
    _categories[categoryIndex]
            .subCategories[subCategoryIndex]
            .products[productIndex]
            .isDescriptionShown =
        !_categories[categoryIndex]
            .subCategories[subCategoryIndex]
            .products[productIndex]
            .isDescriptionShown;
    notifyListeners();
  }

  void reduceItem({int categoryIndex, int subCategoryIndex, int productIndex}) {
    _categories[categoryIndex]
        .subCategories[subCategoryIndex]
        .products[productIndex]
        .count--;
    _selectedItemCount--;
    _selectedProductsTotalPrice = _selectedProductsTotalPrice -
        _categories[categoryIndex]
            .subCategories[subCategoryIndex]
            .products[productIndex]
            .price;
    notifyListeners();
  }

  void increaseItem(
      {int categoryIndex, int subCategoryIndex, int productIndex}) {
    _categories[categoryIndex]
        .subCategories[subCategoryIndex]
        .products[productIndex]
        .count++;
    _selectedItemCount++;
    _selectedProductsTotalPrice = _selectedProductsTotalPrice +
        _categories[categoryIndex]
            .subCategories[subCategoryIndex]
            .products[productIndex]
            .price;
    notifyListeners();
  }

  void setCuttingSize(
      {int categoryIndex,
      int subCategoryIndex,
      int productIndex,
      String cutSize}) {
    _categories[categoryIndex]
        .subCategories[subCategoryIndex]
        .products[productIndex]
        .cuttingSize = cutSize;
    notifyListeners();
  }

  void setProductSize(
      {int categoryIndex,
      int subCategoryIndex,
      int productIndex,
      String itemSize}) {
    _categories[categoryIndex]
        .subCategories[subCategoryIndex]
        .products[productIndex]
        .itemSize = itemSize;
    notifyListeners();
  }

  List<Product> _selectedProducts = [];
  List<Product> get selectedProducts => _selectedProducts;

  Product _selectedOfferProduct;

  void setSelectedDishes() {
    _selectedProducts = [];
    _selectedProductsTotalPrice = 0;
    _selectedItemCount = 0;

    for (var category in _categories) {
      for (var subCategory in category.subCategories) {
        for (var product in subCategory.products) {
          if (product.count > 0) {
            _selectedProductsTotalPrice =
                _selectedProductsTotalPrice + product.totalPrice;
            _selectedProducts.add(product);
            _selectedItemCount = _selectedItemCount + product.count;
          }
        }
      }
    }

    if (_selectedOfferProduct != null) {
      _selectedProductsTotalPrice =
          _selectedProductsTotalPrice + _selectedOfferProduct.totalPrice;
      _selectedProducts.add(_selectedOfferProduct);
      _selectedItemCount = _selectedItemCount + 1;
    }
    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  addOfferItemToSelectedDishes(Product product) {
    _selectedOfferProduct = product;
    _selectedProducts.add(product);
    print(_selectedProducts);
    _selectedProductsTotalPrice =
        _selectedProductsTotalPrice + product.totalPrice;
    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  removeSelectedOfferProduct() {
    _selectedOfferProduct = null;
    setSelectedDishes();
  }

  //double.parse((12.3412).toStringAsFixed(2));

  void addItemInSelectedDishes(int index) {
    _selectedProducts[index].count++;
    _selectedItemCount++;
    _selectedProductsTotalPrice = 0;
    _gst = 0;
    for (var dish in _selectedProducts) {
      print('Hi');
      _selectedProductsTotalPrice =
          _selectedProductsTotalPrice + dish.totalPrice;
      print(dish.gstAmount());
      _gst = _gst + dish.gstAmount();
      print(_gst);
    }
    if (_promoOffer != null) {
      double a = (_promoOffer.discountCalculationType ==
              DiscountCalculationType.rawAmount)
          ? _promoOffer.value.toDouble()
          : _selectedProductsTotalPrice * (_promoOffer.value * 0.01);
      _discountAmount = double.parse((a).toStringAsFixed(2));
    }

    double b = _walletValue * (_walletAmountUsedPercentage * 0.01);
    _walletAmountUsed = double.parse((b).toStringAsFixed(2));

    double otherAmount =
        _selectedProductsTotalPrice + _deliveryCharge - _discountAmount + _gst;

    if (_walletAmountUsed >= otherAmount) {
      _walletAmountUsed = otherAmount;
    }

    if (_deliveryType != null) {
      if (_deliveryType == DeliveryType.scheduledDelivery) {
        if (_selectedProductsTotalPrice >= _deliveryCharges.barAmount) {
          _deliveryCharge = 0;
        } else {
          _deliveryCharge = _deliveryCharges.scheduledDeliveryFee;
        }
      } else {
        if (_selectedProductsTotalPrice >= _deliveryCharges.barAmount) {
          _deliveryCharge = _deliveryCharges.defaultExpressDeliveryFee;
        } else {
          _deliveryCharge = _deliveryCharges.expressDeliveryFee;
        }
      }
    }

    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  void removeItemInSelectedDishes(int index) {
    ///dgkjfdgkfj
    ///
    ///
    ///
    _selectedProducts[index].count--;
    _selectedItemCount--;
    _selectedProductsTotalPrice = 0;
    _gst = 0;
    for (var dish in _selectedProducts) {
      _selectedProductsTotalPrice =
          _selectedProductsTotalPrice + dish.totalPrice;
      _gst = _gst + dish.gstAmount();
    }
    if (_promoOffer != null) {
      double a = (_promoOffer.discountCalculationType ==
              DiscountCalculationType.rawAmount)
          ? _promoOffer.value.toDouble()
          : _selectedProductsTotalPrice * (_promoOffer.value * 0.01);
      _discountAmount = double.parse((a).toStringAsFixed(2));
    }

    double b = _walletValue * (_walletAmountUsedPercentage * 0.01);
    _walletAmountUsed = double.parse((b).toStringAsFixed(2));

    double otherAmount =
        _selectedProductsTotalPrice + _deliveryCharge - _discountAmount + _gst;

    if (_walletAmountUsed >= otherAmount) {
      _walletAmountUsed = otherAmount;
    }

    if (_deliveryType != null) {
      if (_deliveryType == DeliveryType.scheduledDelivery) {
        if (_selectedProductsTotalPrice >= _deliveryCharges.barAmount) {
          _deliveryCharge = 0;
        } else {
          _deliveryCharge = _deliveryCharges.scheduledDeliveryFee;
        }
      } else {
        if (_selectedProductsTotalPrice >= _deliveryCharges.barAmount) {
          _deliveryCharge = _deliveryCharges.defaultExpressDeliveryFee;
        } else {
          _deliveryCharge = _deliveryCharges.expressDeliveryFee;
        }
      }
    }

    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  void removeItemInSelectedItems(int index) {
    _selectedProducts[index].count = 0;
    _selectedItemCount = 0;
    _selectedProducts.removeAt(index);
    _selectedProductsTotalPrice = 0;
    for (var dish in _selectedProducts) {
      _selectedProductsTotalPrice =
          _selectedProductsTotalPrice + dish.totalPrice;
      _selectedItemCount = _selectedItemCount + dish.count;
    }
    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;

    notifyListeners();
  }

  List<Address> _allAddress = [];
  List<Address> get allAddress => _allAddress;

  void setAllAddress(List<Address> newValue) {
    _allAddress = newValue;
    if (newValue.length > 0) {
      _selectedAddress = newValue[0];
    } else {
      _selectedAddress = null;
    }
    notifyListeners();
  }

  int _selectedAddressIndex = 0;
  int get selectedAddressIndex => _selectedAddressIndex;
  Address _selectedAddress;
  Address get selectedAddress => _selectedAddress;

  void setSelectedAddressIndex(int index) {
    _selectedAddressIndex = index;
    _selectedAddress = _allAddress[index];
    notifyListeners();
  }

  void addAddressToList(Address newValue) {
    _selectedAddressIndex = 0;
    _allAddress.add(newValue);
    _selectedAddress = _allAddress[0];
    notifyListeners();
  }

  void removeAddressFromList(Address newValue) {
    int index = _allAddress.indexOf(newValue);
    _selectedAddressIndex = 0;
    _allAddress.removeAt(index);
    if (_allAddress.length > 0) {
      _selectedAddress = _allAddress[0];
    } else {
      _selectedAddress = null;
    }
    notifyListeners();
  }

  double _discountAmount = 0.0;
  double get discountAmount => _discountAmount;
  PromoOffer _promoOffer;
  PromoOffer get promoOffer => _promoOffer;

  void setPromoOffer(PromoOffer newValue) {
    if (newValue != null) {
      _promoOffer = newValue;

      double a = (_promoOffer.discountCalculationType ==
              DiscountCalculationType.rawAmount)
          ? _promoOffer.value.toDouble()
          : _selectedProductsTotalPrice * (_promoOffer.value * 0.01);
      _discountAmount = double.parse((a).toStringAsFixed(2));
    } else {
      _discountAmount = 0.0;
      _promoOffer = null;
    }

    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  double _deliveryCharge = 0.0;
  double get deliveryCharge => _deliveryCharge;

  DeliveryType _deliveryType;

  void setDeliveryCharge({double newValue, DeliveryType deliveryType}) {
    _deliveryType = deliveryType;
    _deliveryCharge = newValue;
    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  double _walletValue = 0.0;
  double get walletValue => _walletValue;
  void setWalletValue(double newValue) {
    if (newValue > 0) {
      _walletValue = newValue;
    } else {
      _walletValue = 0;
    }
    notifyListeners();
  }

  // double _walletAmount = 0.0;
  // double get walletAmount => _walletAmount;
  //
  // void setWalletAmount(double newValue) {
  //   _walletAmount = newValue;
  //   notifyListeners();
  // }

  double _walletAmountUsed = 0.0;
  double get walletAmountUsed => _walletAmountUsed;
  int _walletAmountUsedPercentage = 0;
  int get walletAmountUsedPercentage => _walletAmountUsedPercentage;

  void setWalletUsablePercentage(int percentage, double minBillAmount) {
    if (_selectedProductsTotalPrice > minBillAmount) {
      _walletAmountUsedPercentage = percentage;
      double b = _walletValue * (percentage * 0.01);
      _walletAmountUsed = double.parse((b).toStringAsFixed(2));
    } else {
      _walletAmountUsedPercentage = 0;
      _walletAmountUsed = 0.0;
    }

    double otherAmount =
        _selectedProductsTotalPrice + _deliveryCharge - _discountAmount + _gst;

    if (_walletAmountUsed >= otherAmount) {
      _walletAmountUsed = otherAmount;
    }
    _grandTotal = _selectedProductsTotalPrice +
        _deliveryCharge -
        _walletAmountUsed -
        _discountAmount +
        _gst;
    notifyListeners();
  }

  double _gst = 0.0;
  double get gst => _gst;

  calculateGst() {
    _gst = 0;
    for (Product p in _selectedProducts) {
      _gst = _gst + p.gstAmount();
    }
    notifyListeners();
  }

  double _grandTotal = 0.0;
  double get grandTotal => _grandTotal;

  void getBackToHomeAfterCompleteOrder() {
    _categories = [];
    _selectedItemCount = 0;
    _selectedProducts = [];
    _grandTotal = 0;
    _selectedProductsTotalPrice = 0;
    _gst = 0;
    _deliveryCharge = 0;
    _discountAmount = 0;
    _promoOffer = null;
    _selectedOfferProduct = null;
  }

  List<Order> _liveOrders = List<Order>();
  List<Order> _completedOrders = List<Order>();
  List<Order> _cancelledOrders = List<Order>();

  List<Order> get liveOrders => _liveOrders;
  List<Order> get completedOrders => _completedOrders;
  List<Order> get cancelledOrders => _cancelledOrders;

  void setOrdersHistory(List<Order> newValue) {
    _liveOrders = [];
    _completedOrders = [];
    _cancelledOrders = [];
    _activeOrders = [];
    print('Orders: $newValue');
    if (newValue == null) {
      _liveOrders = null;
      _completedOrders = null;
      _cancelledOrders = null;
    } else {
      for (Order order in newValue) {
        if (order.orderStatusName == OrderStatusName.completed) {
          _completedOrders.add(order);
        } else if (order.orderStatusName == OrderStatusName.cancelled) {
          _cancelledOrders.add(order);
        } else {
          _liveOrders.add(order);
          if (_activeOrders.length == 0) {
            _activeOrders.add(order);
          }
        }
      }
    }
    notifyListeners();
  }

  void setOrderRatingsStatus(int index) {
    _completedOrders[index].isRatingsGiven = true;
    notifyListeners();
  }

  List<Order> _activeOrders = [];
  List<Order> get activeOrders => _activeOrders;
  void setActiveOrders(List<Order> newValue) {
    _activeOrders = newValue;
    print(_activeOrders);
    notifyListeners();
  }

  void removeOrderFromActiveOrder({int orderId}) {
    _activeOrders = [];
    notifyListeners();
  }

  void removeOrder({int orderType, int index}) {
    if (orderType == 1) {
      //Completed Orders
      _completedOrders.removeAt(index);
    } else if (orderType == 2) {
      //Cancelled Orders
      _cancelledOrders.removeAt(index);
    }

    notifyListeners();
  }

  List<Product> _filteredProducts = [];
  List<Product> get filteredProducts => _filteredProducts;

  void filterProducts(String value) {
    _filteredProducts = [];
    if (value != '') {
      for (Category c in _categories) {
        for (SubCategory s in c.subCategories) {
          for (Product p in s.products) {
            String combined =
                p.name + p.name.toUpperCase() + p.name.toLowerCase();
            if (combined.contains(value)) {
              _filteredProducts.add(p);
            }
          }
        }
      }
    }
    notifyListeners();
  }

  void setDescriptionStatusForFilterProducts({Product product, int index}) {
    _filteredProducts[index].isDescriptionShown =
        !filteredProducts[index].isDescriptionShown;
    notifyListeners();
  }

  void increaseItemOfFilteredProducts({int index}) {
    _filteredProducts[index].count++;
    _selectedItemCount++;
    _selectedProductsTotalPrice =
        _selectedProductsTotalPrice + _filteredProducts[index].price;
    notifyListeners();
  }

  void reduceItemOfFilteredProducts({int index}) {
    _filteredProducts[index].count--;
    _selectedItemCount--;
    _selectedProductsTotalPrice =
        _selectedProductsTotalPrice - _filteredProducts[index].price;
    notifyListeners();
  }

  void setCuttingSizeOfFilteredProducts({int index, String cutSize}) {
    _filteredProducts[index].cuttingSize = cutSize;
    notifyListeners();
  }

  void setProductSizeOfFilteredProducts({int index, String itemSize}) {
    _filteredProducts[index].itemSize = itemSize;
    notifyListeners();
  }

  bool _isAdvImgToShow = true;
  bool get isAdvImgToShow => _isAdvImgToShow;
  void setAdvertisementImageStatus(bool newValue) {
    _isAdvImgToShow = newValue;
    notifyListeners();
  }

  DeliveryCharges _deliveryCharges;
  DeliveryCharges get deliveryCharges => _deliveryCharges;
  setDeliveryCharges(DeliveryCharges newValue) {
    _deliveryCharges = newValue;
    notifyListeners();
  }
}
