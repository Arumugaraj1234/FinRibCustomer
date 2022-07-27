import 'dart:convert';
import 'dart:io';
import 'package:finandrib/models/address.dart';
import 'package:finandrib/models/banner.dart';
import 'package:finandrib/models/category.dart';
import 'package:finandrib/models/init_settings.dart';
import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/models/order.dart';
import 'package:finandrib/models/order_status.dart';
import 'package:finandrib/models/product.dart';
import 'package:finandrib/models/promo_offer.dart';
import 'package:finandrib/models/reward.dart';
import 'package:finandrib/models/rider.dart';
import 'package:finandrib/models/selected_product_model.dart';
import 'package:finandrib/models/shop.dart';
import 'package:finandrib/models/sub_category.dart';
import 'package:finandrib/screens/delivery_type_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

class Wallet {
  double availableWalletAmount;
  int usablePercentage;
  double minBillAmountForDiscount;

  Wallet(
      {this.availableWalletAmount,
      this.usablePercentage,
      this.minBillAmountForDiscount});
}

class DeliveryCharges {
  double barAmount;
  double defaultExpressDeliveryFee;
  double scheduledDeliveryFee;
  double expressDeliveryFee;
  int isExpressDeliveryAvailable; //1-Show, 0-Hide

  DeliveryCharges(
      {this.barAmount,
      this.defaultExpressDeliveryFee,
      this.scheduledDeliveryFee,
      this.expressDeliveryFee,
      this.isExpressDeliveryAvailable});
}

class NetworkServices {
  static final NetworkServices shared = NetworkServices();

  void storeLoginStatus(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(kUserLoggedInKey, newValue);
  }

  void storeUserId(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(kUserIdKey, newValue);
  }

  void storeUserDetails(
      String name, String email, String mobileNo, String referralCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> userDetails = {
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'referralCode': referralCode
    };
    String userDetailsStr = jsonEncode(userDetails);
    prefs.setString(kUserDetailsKey, userDetailsStr);
  }

  Future<NetworkResponse> getInitSettings(BuildContext context) async {
    NetworkResponse responseValue;
    try {
      http.Response response =
          await http.post(kUrlToGetInitSettings, headers: kHeader);
      String data = response.body;

      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var responseData = jsonData['Data'];
          String latestAppVersion = responseData['version'];
          double latVersion = double.parse(latestAppVersion);
          int appStatus = responseData['status'];
          String appInstruction = responseData['message'];
          String googleKey = responseData['google_api_key'] ?? '';
          String razorKey = responseData['razor_pay_key'] ?? '';
          int isWithOffer = responseData["with_offer"] ?? 0;
          Provider.of<DataServices>(context, listen: false)
              .setGoogleAndRazorPayKeys(
                  googleApiKey: googleKey,
                  razorPayKey: razorKey,
                  isWithOffer: isWithOffer);
          InitSettings initSettings = InitSettings(
              status: appStatus,
              message: appInstruction,
              latestVersion: latVersion);

          List<BannerModel> banners = [];

          var bannersData = jsonData['Banners'];
          String baseImageUrl = jsonData['URL'];

          for (var b in bannersData) {
            int bannerId = b["id"] ?? 0;
            String imageName = b["image_path"] ?? "";
            String imageUrl = baseImageUrl + imageName;
            int categoryId = b["main_category_id"] ?? 0;
            int subCategoryId = b["sub_category_id"] ?? 0;
            int productId = b["dish_id"] ?? 0;

            BannerModel banner = BannerModel(
                bannerId, imageUrl, categoryId, subCategoryId, productId);
            banners.add(banner);
          }

          Provider.of<DataServices>(context, listen: false)
              .setBannersData(banners);

          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: initSettings);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getAllShops({BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      http.Response response =
          await http.post(kUrlToGetAllShops, headers: kHeader);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var shopsData = jsonData['Data'];
          List<Shop> shops = [];
          for (var s in shopsData) {
            var shop = s['hotel'];
            int shopId = shop['hotel_id'];
            String shopName = shop['name'];
            String shopAddress = shop['address'];
            int shopStatusFlag = shop['flg'];
            String shopRemarks = shop['reason'] ?? '';
            var postalData = s['post_codes'];
            List<String> pinCodes = [];
            for (var p in postalData) {
              String postal = p['PostCode'];
              pinCodes.add(postal);
            }
            int advFlag = s['show_ads'];
            double deliveryCharge = shop['express_charge'] ?? 0;
            bool isAdvertisementToShow = advFlag == 1 ? true : false;
            String advertisementUrl = s['adv_url'];
            Shop sM = Shop(
                id: shopId,
                name: shopName,
                address: shopAddress,
                pinCodes: pinCodes,
                flag: shopStatusFlag,
                remarks: shopRemarks,
                isAdvImageToShow: isAdvertisementToShow,
                advImageUrl: advertisementUrl,
                deliveryCharge: deliveryCharge);
            shops.add(sM);
          }
          Provider.of<DataServices>(context, listen: false).setAllShops(shops);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: shops);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getProductByShop(
      {BuildContext context, int shopId}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['hotel_id'] = shopId;
      print(params);
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToGetProductByShop, headers: kHeader, body: body);

      String data = response.body;
      print(body);
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var categoriesData = jsonData['Data'];
          List<Category> categories = [];
          for (var category in categoriesData) {
            String categoryName = category['category_name'];
            int categoryId = int.parse(category['category_id']);
            String categoryIconLink = category['category_icon'];
            List<SubCategory> totalSubCategories = [];
            var subCategories = category['sub_list'];
            for (var subCategory in subCategories) {
              int subCategoryId = int.parse(subCategory['sub_category_id']);
              int availableStocksInSubCategory = subCategory['stocks_count'];
              String subCategoryName = subCategory['sub_category_name'];
              String subCategoryIconLink = subCategory['sub_category_icon'];
              String subCategoryThumbnail =
                  subCategory['sub_category_thumbnail'];
              double subCategoryOriginalPrice = subCategory['rate'] ?? 0.0;
              double subCategoryDiscountedPrice =
                  subCategory['spl_rate'] ?? 0.0;
              String subCategoryGrossWeight = subCategory['gross_weight'] ?? '';
              String subCategoryNetWeight = subCategory['net_weight'] ?? '';
              String subCategoryQtyDescription =
                  'Gross: $subCategoryGrossWeight';
              if (subCategoryNetWeight != '') {
                subCategoryQtyDescription =
                    '$subCategoryQtyDescription  Net: $subCategoryNetWeight';
              }

              List<Product> totalProducts = [];
              var products = subCategory['sub_dishes'];
              for (var product in products) {
                int productId = product['dish_id'];
                String productName = product['dish_name'];
                String productIconLink = product['dish_icon'];

                String productDescription = product['description'] ?? '';
                int productTypeFlag = product['dish_type'];
                int availableNoOfStock = product['dish_stocks'];
                String productThumbnail = product['dish_thumbnail'];
                if (productThumbnail.endsWith('/')) {
                  productThumbnail = productIconLink;
                }
                int gstPercentage = product['gst'] ?? 0;
                int productGramsQtyInInt = product['grams'] ?? 0;
                double productGramsQtyInDouble =
                    productGramsQtyInInt.toDouble();
                String productGrossWeight = product['gross_weight'] ?? '';
                String productNetWeight = product['net_weight'] ?? '';
                String productQtyDescription = 'Gross: $productGrossWeight';
                if (productNetWeight != '') {
                  productQtyDescription =
                      '$productQtyDescription  Net: $productNetWeight';
                }
                //int cuttingOption = dish['slice_opt'] ?? 0;
                double productPrice = product['rate'];
                double productOffRate = product['spl_rate'] ?? 0.0;

                List<dynamic> cuttingOptionsDynamic = product['cuttings'];
                List<String> cuttingOptions = [];
                for (var c in cuttingOptionsDynamic) {
                  cuttingOptions.add('$c');
                }
                bool isCutOptionsAvailable =
                    (cuttingOptions.length > 0) ? true : false;
                List<dynamic> productSizeOptionDynamic = product['sizes'];
                List<String> productSizeOption = [];
                for (var p in productSizeOptionDynamic) {
                  productSizeOption.add('$p');
                }
                bool isProductSizeOptionsAvailable =
                    (productSizeOption.length > 0) ? true : false;

                Product productModel = Product(
                    id: productId,
                    imageLink: productIconLink,
                    name: productName,
                    price: productOffRate == 0 ? productPrice : productOffRate,
                    quantity: '1 KiloGrams',
                    count: 0,
                    availableStocks: availableNoOfStock,
                    isDescriptionShown: false,
                    cuttingSize: '',
                    description: productDescription,
                    qtyDescription: productQtyDescription,
                    cutOffPrice: productOffRate == 0 ? 0 : productPrice,
                    isCuttingOptionsAvailable: isCutOptionsAvailable,
                    cuttingSizeOptions: cuttingOptions,
                    isItemSizeOptionsAvailable: isProductSizeOptionsAvailable,
                    itemSizeOptions: productSizeOption,
                    itemSize: '',
                    grams: productGramsQtyInDouble,
                    thumbNail: productThumbnail,
                    gstPercentage: gstPercentage);
                totalProducts.add(productModel);
              }

              SubCategory subCategoryModel = SubCategory(
                  id: subCategoryId,
                  name: subCategoryName,
                  iconImageLink: subCategoryIconLink,
                  thumbnail: subCategoryThumbnail,
                  quantity: subCategoryQtyDescription,
                  originalPrice: subCategoryDiscountedPrice == 0
                      ? subCategoryOriginalPrice
                      : subCategoryDiscountedPrice,
                  discountPrice: subCategoryDiscountedPrice == 0
                      ? 0
                      : subCategoryOriginalPrice,
                  products: totalProducts,
                  availableStocks: availableStocksInSubCategory);

              totalSubCategories.add(subCategoryModel);
            }

            Category categoryModel = Category(
                id: categoryId,
                name: categoryName,
                image: categoryIconLink,
                subCategories: totalSubCategories);
            print(categoryModel.name);
            categories.add(categoryModel);
          }

          Provider.of<DataServices>(context, listen: false)
              .setCategories(categories);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: categories);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        print('Aru: $message');
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      print('Aru: $err');
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> requestForOtp(String phoneNo) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['phone_no'] = phoneNo;
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToRequestOtp, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        String userName = jsonData['Name'];
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: userName);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: -1, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: -1, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> registerNewUser(
      {String phoneNo,
      String name,
      String email,
      int regFrom,
      String uid,
      String password,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      String googleId = '4';
      String facebookId = '1';
      if (regFrom == 2) {
        googleId = uid;
      } else if (regFrom == 3) {
        facebookId = uid;
      }
      var params = new Map<String, dynamic>();
      params['phone_no'] = phoneNo;
      params['name'] = name;
      params['email'] = email;
      params['google_id'] = googleId;
      params['facebook_id'] = facebookId;
      params['login_type'] = regFrom;
      params['password'] = password;

      var body = json.encode(params);

      http.Response response =
          await http.post(kUrlToRegisterNewUser, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          var userData = jsonData['Data'];

          int userId = userData['customer_id'];
          String name1 = userData['name'];
          String email1 = userData['email'];
          String referralCode = userData['ref_code'];

          storeUserId(userId);
          storeLoginStatus(true);
          storeUserDetails(name1, email1, phoneNo, referralCode);

          Provider.of<DataServices>(context, listen: false).setUserId(userId);
          Provider.of<DataServices>(context, listen: false)
              .setUserLoggedInStatus(true);
          Map<String, String> userDetails = {
            'name': name,
            'email': email,
            'mobileNo': phoneNo
          };
          Provider.of<DataServices>(context, listen: false)
              .setUserDetails(userDetails);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> verifyOtp(
      {String phoneNo,
      String otp,
      String fcmToken,
      String userName,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['phone_no'] = phoneNo;
      params['otp'] = otp;
      params['token'] = fcmToken;
      params['name'] = userName;
      var body = json.encode(params);

      print(body);

      http.Response response =
          await http.post(kUrlToOtpVerification, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        print(responseMessage);

        if (responseCode == 1) {
          // Otp got verified successfully. Parse the data
          var responseData = jsonData['Data'];
          int userId = responseData['customer_id'];
          String name = responseData['name'];
          String email = responseData['email'];
          String referralCode = responseData['ref_code'];
          storeUserId(userId);
          storeLoginStatus(true);
          storeUserDetails(name, email, phoneNo, referralCode);

          Provider.of<DataServices>(context, listen: false).setUserId(userId);
          Provider.of<DataServices>(context, listen: false)
              .setUserLoggedInStatus(true);
          Map<String, String> userDetails = {
            'name': name,
            'email': email,
            'mobileNo': phoneNo
          };
          Provider.of<DataServices>(context, listen: false)
              .setUserDetails(userDetails);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  void logout(BuildContext context) {
    storeUserId(0);
    storeLoginStatus(false);
    storeUserDetails('', '', '', '');

    Provider.of<DataServices>(context, listen: false).setUserId(0);
    Provider.of<DataServices>(context, listen: false)
        .setUserLoggedInStatus(false);
    Map<String, String> userDetails = {'name': '', 'email': '', 'mobileNo': ''};
    Provider.of<DataServices>(context, listen: false)
        .setUserDetails(userDetails);
    Provider.of<DataServices>(context, listen: false).setActiveOrders([]);
  }

  Future<NetworkResponse> loginWithPassword(
      {String phoneNo,
      String password,
      String fcmToken,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['phone_no'] = phoneNo;
      params['password'] = password;
      params['token'] = fcmToken;
      var body = json.encode(params);

      http.Response response = await http.post(kUrlToLoginWithPassword,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          // Otp got verified successfully. Parse the data
          var responseData = jsonData['Data'];
          int userId = responseData['customer_id'];
          String name = responseData['name'];
          String email = responseData['email'];
          String referralCode = responseData['ref_code'];
          storeUserId(userId);
          storeLoginStatus(true);
          storeUserDetails(name, email, phoneNo, referralCode);

          Provider.of<DataServices>(context, listen: false).setUserId(userId);
          Provider.of<DataServices>(context, listen: false)
              .setUserLoggedInStatus(true);
          Map<String, String> userDetails = {
            'name': name,
            'email': email,
            'mobileNo': phoneNo
          };
          Provider.of<DataServices>(context, listen: false)
              .setUserDetails(userDetails);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> changePassword(
      {String mobileNo, String otp, String newPassword}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['phone_no'] = mobileNo;
      params['otp'] = otp;
      params['new_password'] = newPassword;
      var body = json.encode(params);

      http.Response response = await http.post(kUrlToChangeThePassword,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getAllAddress(
      int shopId, BuildContext context) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      print(userId);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['hotel_id'] = shopId;
      print(params);
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToGetAllAddress, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          var addresses = jsonData['Data'];
          List<Address> allAddress = [];
          for (var address in addresses) {
            int addressId = address['fav_addr_id'];
            String fullAddress = address['address'];
            double lat = address['latitude'];
            double lon = address['longitude'];
            String postal = address['post_code'] ?? '';

            Address aM = Address(
                id: addressId,
                fullAddress: fullAddress,
                latitude: lat,
                longitude: lon,
                postal: postal);
            allAddress.add(aM);
          }
          Provider.of<DataServices>(context, listen: false)
              .setAllAddress(allAddress);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: allAddress);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> addOrRemoveAddress(
      {Address address, int type, int shopId, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);

      var params = new Map<String, dynamic>();
      params['fav_addr_id'] = address.id;
      params['customer_id'] = userId;
      params['hotel_id'] = shopId;
      params['address'] = address.fullAddress;
      params['post_code'] = address.postal;
      params['latitude'] = address.latitude;
      params['longitude'] = address.longitude;
      params['type'] = type;
      print(params);

      var body = json.encode(params);

      http.Response response = await http.post(kUrlToAddOrDeleteAddress,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          if (type == 1) {
            var responseData = jsonData['Data'];
            int addressId = responseData['fav_addr_id'];
            Address resultAddress = address;
            resultAddress.id = addressId;
            Provider.of<DataServices>(context, listen: false)
                .addAddressToList(resultAddress);
            responseValue = NetworkResponse(
                code: responseCode,
                message: responseMessage,
                data: resultAddress);
          } else {
            Provider.of<DataServices>(context, listen: false)
                .removeAddressFromList(address);
            responseValue = NetworkResponse(
                code: responseCode, message: responseMessage, data: null);
          }
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getCustomerInfo() async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      print(params);
      var body = json.encode(params);

      http.Response response =
          await http.post(kUrlToGetCustomerInfo, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          var data = jsonData['Data'];
          double walletAmt = data['wallet'] ?? 0.0;
          int percentage = jsonData['Wallet'] ?? 0;
          double minDisAmount = jsonData['MinDisAmt'] ?? 0.0;
          Wallet wallet = Wallet(
              availableWalletAmount: walletAmt,
              usablePercentage: percentage,
              minBillAmountForDiscount: minDisAmount);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: wallet);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  // Code 1 - Coupen, 2 - Voucher
  //Type 1 - Raw Amount, 2 - Percentage

  Future<NetworkResponse> applyPromoCode(
      {String promo, int shopId, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['hotel_id'] = shopId;
      params['code'] = promo;
      var body = json.encode(params);

      http.Response response =
          await http.post(kUrlToApplyPromoCode, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1 || responseCode == 2) {
          var promoCodeData = jsonData['Data'];
          String promoCode = promoCodeData['code'];
          int calType = promoCodeData['type'];
          DiscountCalculationType disCalType = calType == 1
              ? DiscountCalculationType.rawAmount
              : DiscountCalculationType.percentage;
          PromoType promoType =
              responseCode == 1 ? PromoType.coupon : PromoType.voucher;
          int value = promoCodeData['value'] ?? 0;
          PromoOffer model = PromoOffer(
              promoCode: promoCode,
              promoType: promoType,
              discountCalculationType: disCalType,
              value: value,
              promoTypeFlag: responseCode);
          Provider.of<DataServices>(context, listen: false)
              .setPromoOffer(model);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: model);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  String changeDateFormat(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req =
        formatDate(dateTime, [MM, dd, ', ', yyyy, ', ', hh, ':', nn, am]);
    return req;
  }

  String changeDateFormatOnlyDate(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req = formatDate(dateTime, [
      MM,
      dd,
      ', ',
      yyyy,
      ', ',
    ]);
    return req;
  }

  Future<NetworkResponse> placeOrder(
      {int hotelId,
      int orderType,
      Address address,
      int paymentType,
      List<SelectedProduct> dishes,
      String couponCode,
      int couponType,
      String transactionId,
      double walletAmount,
      String splInst,
      String deliveryTime,
      int deliverySlotId,
      double gst,
      double deliveryCharge}) async {
    NetworkResponse responseValue;
    try {
      List<Map<String, dynamic>> dishDetails = [];
      for (var di in dishes) {
        var abc = new Map<String, dynamic>();
        abc['dish_id'] = di.dish_id;
        abc['qty'] = di.qty;
        abc['dish_size'] = di.itemSize;
        abc['dish_cutting'] = di.cutSize;
        abc['rate'] = di.rate;
        abc['is_offer'] = di.offerFlag;
        dishDetails.add(abc);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['hotel_id'] = hotelId;
      params['customer_id'] = userId;
      params['dishid_qty_list'] = dishDetails;
      params['order_type'] = orderType;
      params['delivery_address'] = address.fullAddress;
      params['post_code'] = address.postal;
      params['delivery_lat'] = address.latitude;
      params['delivery_lon'] = address.longitude;
      params['wallet_amount'] = walletAmount;
      params['payment_type'] = paymentType;
      params['txn_id'] = transactionId;
      params['spl_inst'] = splInst;
      params['delivery_time'] = deliveryTime;
      params['coupon_code'] = couponCode;
      params['coupon_type'] = couponType;
      params['delivery_slot'] = deliverySlotId;
      params['order_from'] = Platform.isIOS ? 4 : 3;
      params['tax'] = gst;
      params['delivery_charge'] = deliveryCharge;
      print(params);
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToSaveOrder, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var rewardData = jsonData['Card'];
          int rewardId = rewardData['scratch_id'];
          int orderId = rewardData['order_id'];
          double amount = rewardData['amount'];
          String dateTime = rewardData['order_date'];
          String date = changeDateFormat(dateTime);
          bool isScratched = rewardData['scratched'] == 0 ? false : true;
          Reward rM = Reward(
              id: rewardId,
              orderId: orderId,
              isScratched: isScratched,
              orderDate: date,
              amount: amount);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: rM);
        } else if (responseCode == 2) {
          var resData = jsonData['Data'];
          int orderId = resData['order_id'];
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: orderId);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  showAlertDialog(
      BuildContext context, String title, String msg, Function onPressed) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: onPressed,
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<NetworkResponse> scratchCard(
      {int cardId, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['scratch_id'] = cardId;
      var body = json.encode(params);

      http.Response response =
          await http.post(kUrlToScratchReward, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        double walletValue = jsonData['Wallet'] ?? 0.0;
        Provider.of<DataServices>(context, listen: false)
            .setWalletValue(walletValue);
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getAllRewards(BuildContext context) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      var body = json.encode(params);
      print(body);
      http.Response response =
          await http.post(kUrlToGetAllRewards, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        print(jsonData);
        print(responseMessage);
        if (responseCode == 1) {
          var resdata = jsonData['Data'];
          double availableWalletValue = jsonData['Wallet'] ?? 0;
          Provider.of<DataServices>(context, listen: false)
              .setWalletValue(availableWalletValue);
          List<Reward> rewards = [];
          for (var rewardData in resdata) {
            int rewardId = rewardData['scratch_id'];
            int orderId = rewardData['order_id'];
            int scratchFlag = rewardData['scratched'];
            bool isScratched = scratchFlag == 0 ? false : true;
            String orderDate = rewardData['order_date'];
            String date = changeDateFormat(orderDate);
            double amount = rewardData['amount'];
            Reward rM = Reward(
                id: rewardId,
                orderId: orderId,
                isScratched: isScratched,
                orderDate: date,
                amount: amount);
            rewards.add(rM);
          }

          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: rewards);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> redeemReferralCode(
      String referralCode, BuildContext context) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['ref_code'] = referralCode;
      var body = json.encode(params);

      http.Response response = await http.post(kUrlToRedeemReferralCode,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          double walletAmount = jsonData['Data']['wallet'];
          Provider.of<DataServices>(context, listen: false)
              .setWalletValue(walletAmount);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: walletAmount);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getOrdersHistory({BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToGetOrdersHistory, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];

        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var ordersData = jsonData['Data'];
          List<Order> orders = [];
          for (var orderData in ordersData) {
            int riderId = orderData['rider_id'];
            int orderStatusFlag = orderData['order_type'];
            OrderStatusName orderStatusName;
            if (orderStatusFlag == 1) {
              orderStatusName = OrderStatusName.active;
            } else if (orderStatusFlag == 2) {
              orderStatusName = OrderStatusName.completed;
            } else {
              orderStatusName = OrderStatusName.cancelled;
            }
            var orderDetails = orderData['order'];
            int orderId = orderDetails['order_id'];
            int hotelId = orderDetails['hotel_id'];
            int supplierId = orderDetails['supplier_id'];
            int tableId = orderDetails['table_id'];
            int orderType = orderDetails['order_type'];
            String deliveryAddress = orderDetails['delivery_address'];
            var rating = orderDetails['rating'];
            bool isRatingGiven = (rating == null) ? false : true;
            double deliveryLat = orderDetails['delivery_lat'];
            double deliveryLon = orderDetails['delivery_lon'];
            double baseAmount = orderDetails['amount'];
            double discount = orderDetails['discount'];
            double tax = orderDetails['tax'];
            double deliveryCharge = orderDetails['delivery_charge'] ?? 0.0;
            double walletUsed = orderDetails['wallet'] ?? 0.0;
            double totalAmount = orderDetails['total'];
            int paymentType = orderDetails['payment_type'];
            int paymentStatus = orderDetails['payment_status'];
            int orderStatus = orderDetails['order_status'];
            String orderStatusDesc = orderData['order_status'];
            String fromLocation = orderData['hotel_name'];

            Color orderStatusColorCode;
            bool isCancelBtnToShow = true;
            switch (orderStatus) {
              case 1:
                //orderStatusDesc = 'Requested';
                orderStatusColorCode = Colors.blue;
                isCancelBtnToShow = true;
                break;
              case 2:
                //orderStatusDesc = 'Created';
                orderStatusColorCode = Colors.blue;
                isCancelBtnToShow = true;
                break;
              case 3:
                //orderStatusDesc = 'In kitchen';
                orderStatusColorCode = Colors.yellow;
                isCancelBtnToShow = true;
                break;
              case 4:
                //orderStatusDesc = 'On the way';
                orderStatusColorCode = Colors.orange;
                isCancelBtnToShow = true;
                break;
              case 5:
                //orderStatusDesc = 'Delivered';
                orderStatusColorCode = Colors.teal;
                isCancelBtnToShow = false;
                break;
              case 6:
                //orderStatusDesc = 'Completed';
                orderStatusColorCode = Colors.green;
                isCancelBtnToShow = false;
                break;
              case 7:
                //orderStatusDesc = 'Cancelled';
                orderStatusColorCode = Colors.red;
                isCancelBtnToShow = false;
                break;
              default:
                //orderStatusDesc = '';
                orderStatusColorCode = Colors.blue;
                isCancelBtnToShow = false;
                break;
            }

            var serverDate = orderDetails['order_date'];
            String orderDate = changeDateFormat(serverDate);
            int deliverySlotId = orderDetails['delivery_slot'];
            var delDate = orderDetails['delivery_time'];
            String deliveryDate = changeDateFormat(delDate);
            String scheduledTime = '';
            if (deliverySlotId > 0) {
              String deliveryDateOnly = changeDateFormatOnlyDate(delDate);
              String slotName = orderData['delivery_slot'];
              scheduledTime = deliveryDateOnly + slotName;
            }
            var orderedItems = orderData['items'];
            String orderTypeDesc = '';
            switch (orderType) {
              case 2:
                orderTypeDesc = 'Door Delivery';
                break;
              case 3:
                orderTypeDesc = 'Door Delivery';
                break;
              case 4:
                orderTypeDesc = 'Door Delivery';
                break;
              default:
                orderTypeDesc = '';
                break;
            }
            List<ProductInOrder> dishes = [];
            String dishesName = '';

            for (var item in orderedItems) {
              int dishId = item['dish_id'];
              String dishName = item['dish_name'];
              String dishIconLink = item['dish_icon'];
              double price = item['rate'];
              String description = item['description'];
              int dishTypeFlag = item['dish_type'];
              double qty = item['qty'];
              int quantity = qty.toInt();
              String hint = dishName + dishName.toLowerCase();
              String grossWeight = item['gross_weight'] ?? '';
              String netWeight = item['net_weight'] ?? '';
              String qtyDescription = 'Gross: $grossWeight';
              if (netWeight != '') {
                qtyDescription = '$qtyDescription  Net: $netWeight';
              }
              //int cuttingOption = item['slice_opt'] ?? 0;
              double offRate = item['spl_rate'] ?? 0.0;
              //List<dynamic> cuttingOptionsDynamic = item['cuttings'] ?? [];
              //List<dynamic> cuttingOptionsDynamic = [];
              String cuttingOptions = item['cuttings'] ?? '';
              // for (var c in cuttingOptionsDynamic) {
              //   cuttingOptions.add('$c');
              // }
              bool isCutOptionsAvailable = true;
              //(cuttingOptions.length > 0) ? true : false;
              //List<dynamic> productSizeOptionDynamic = item['sizes'] ?? [];
              //List<dynamic> productSizeOptionDynamic = [];
              String productSizeOption = item['sizes'] ?? '';
              // for (var p in productSizeOptionDynamic) {
              //   productSizeOption.add(p);
              // }
              bool isProductSizeOptionsAvailable = true;
              //(productSizeOption.length > 0) ? true : false;
              ProductInOrder dishModel = ProductInOrder(
                  id: dishId,
                  imageLink: dishIconLink,
                  name: dishName,
                  price: offRate == 0 ? price : offRate,
                  count: quantity,
                  quantity: '1 Kilo Grams',
                  availableStocks: 0,
                  isDescriptionShown: false,
                  cuttingSize: '',
                  description: description,
                  qtyDescription: qtyDescription,
                  cutOffPrice: offRate == 0 ? 0 : price,
                  isCuttingOptionsAvailable: isCutOptionsAvailable,
                  cuttingSizeOption: cuttingOptions,
                  isItemSizeOptionsAvailable: isProductSizeOptionsAvailable,
                  itemSize: '',
                  itemSizeOption: productSizeOption,
                  grams: 0.0,
                  thumbNail: '');
              dishes.add(dishModel);
              if (dishesName == '') {
                dishesName = dishName + ' x ' + quantity.toString();
              } else {
                dishesName =
                    dishesName + ', ' + dishName + ' x ' + quantity.toString();
              }
            }

            Order oM = Order(
                orderId: orderId,
                shopId: hotelId,
                supplierId: supplierId,
                tableId: tableId,
                orderType: orderType,
                deliveryAddress: deliveryAddress,
                deliveryLatitude: deliveryLat,
                deliveryLongitude: deliveryLon,
                amount: baseAmount,
                discount: discount,
                tax: tax,
                totalAmount: totalAmount,
                paymentType: paymentType,
                paymentStatus: paymentStatus,
                orderStatus: orderStatus,
                orderDate: orderDate,
                products: dishes,
                productName: dishesName,
                orderTypeDesc: orderTypeDesc,
                orderStatusColorCode: orderStatusColorCode,
                orderStatusDesc: orderStatusDesc,
                isCancelButtonToShow: isCancelBtnToShow,
                fromLocation: fromLocation,
                deliveryTime: deliveryDate,
                riderId: riderId,
                deliveryCharge: deliveryCharge,
                walletUsed: walletUsed,
                scheduledDeliveryTime: scheduledTime,
                deliverySlotId: deliverySlotId,
                orderStatusName: orderStatusName,
                isRatingsGiven: isRatingGiven);
            orders.add(oM);
          }

          Provider.of<DataServices>(context, listen: false)
              .setOrdersHistory(orders);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: orders);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> cancelCard(int orderId) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;
      var body = json.encode(params);

      http.Response response =
          await http.post(kUrlToCancelOrder, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> updateProfile(
      {String fullName,
      String email,
      String phone,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['name'] = fullName;
      params['email'] = email;
      params['phone_no'] = phone;

      var body = json.encode(params);
      http.Response response = await http.post(kUrlToUpdateProfileDetails,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          Map<String, String> userDetails = {
            'name': fullName,
            'email': email,
            'mobileNo': phone
          };
          Provider.of<DataServices>(context, listen: false)
              .setUserDetails(userDetails);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        } else if (responseCode == 2) {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> verifyOtpToResetMobileNo(
      {String otp,
      String mobileNo,
      String name,
      String email,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['phone_no'] = mobileNo;
      params['otp'] = otp;

      var body = json.encode(params);
      http.Response response = await http.post(kUrlToVerifyOtpToResetMobileNo,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          Map<String, String> userDetails = {
            'name': name,
            'email': email,
            'mobileNo': mobileNo
          };
          Provider.of<DataServices>(context, listen: false)
              .setUserDetails(userDetails);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getRiderLocation(
      {int riderId, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['rider_id'] = riderId;

      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToTrackRider, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var resData = jsonData['Data'];
          String riderName = resData['name'];
          String phoneNo = resData['phone_no'];
          double latitude = resData['latitude'];
          double longitude = resData['longitude'];

          Rider rider = Rider(
              name: riderName,
              phone: phoneNo,
              latitude: latitude,
              longitude: longitude);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: rider);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> trackOrder(
      {int orderId, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;

      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToTrackOrder, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var statusData = jsonData['Data'];
          List<OrderStatus> totalStatus = [];
          for (var orderStatus in statusData) {
            String name = orderStatus['status'];
            String time = orderStatus['time'];
            int statusFlag = orderStatus['IsTick'];
            TickStatus status =
                statusFlag == 0 ? TickStatus.unselected : TickStatus.selected;
            OrderStatus oS =
                OrderStatus(name: name, time: time, status: status);
            totalStatus.add(oS);
          }
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: totalStatus);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> updatePaymentStatus(
      {int orderId,
      String txnId,
      int payResponse,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;
      params['txn_id'] = txnId;
      params['response'] = payResponse;

      var body = json.encode(params);
      http.Response response = await http.post(kUrlToUpdatePaymentStatus,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var resData = jsonData['Data'];

          var rewardData = jsonData['Card'];
          int rewardId = rewardData['scratch_id'] ?? 0;
          int orderId = rewardData['order_id'] ?? 0;
          double amount = rewardData['amount'] ?? 0;
          //String dateTime = rewardData['order_date'];
          //String date = changeDateFormat(dateTime);
          bool isScratched = rewardData['scratched'] == 0 ? false : true;
          Reward rM = Reward(
              id: rewardId,
              orderId: orderId,
              isScratched: isScratched,
              orderDate: '',
              amount: amount);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: rM);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> removeOrderFromHistory(
      {int orderId,
      int indexOfOrder,
      int orderType,
      BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;
      print(params);
      var body = json.encode(params);
      http.Response response = await http.post(kUrlToRemoveOrderFromHistory,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          Provider.of<DataServices>(context, listen: false)
              .removeOrder(orderType: orderType, index: indexOfOrder);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getTimeSlots({int shopId, String date}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['hotel_id'] = shopId;
      params['Date'] = date;
      print(params);
      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToGetTimeSlot, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var resData = jsonData['Data'];
          bool isSelectedFound = false;
          List<TimeSlot> timeSlots = [];
          for (var tS in resData) {
            int slotId = tS['slot_id'];
            String name = tS['slot'];
            int enableFlag = tS['enable'];
            print(enableFlag);
            bool enableStatus = enableFlag == 1 ? true : false;
            bool isSelected = false;
            if (isSelectedFound == false) {
              if (enableStatus) {
                isSelected = true;
                isSelectedFound = true;
              }
            }
            TimeSlot timeSlot = TimeSlot(
                id: slotId,
                name: name,
                isEligible: enableStatus,
                isSelected: isSelected);
            timeSlots.add(timeSlot);
          }
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: timeSlots);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getLiveOrders({BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey) ?? 0;
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      print(params);
      var body = json.encode(params);
      http.Response response = await http.post(kUrlToCheckForLiveOrder,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];

        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var orderData = jsonData['Data'];
          List<Order> orders = [];
          int riderId = orderData['rider_id'];
          int orderStatusFlag = orderData['order_type'];
          OrderStatusName orderStatusName;
          if (orderStatusFlag == 1) {
            orderStatusName = OrderStatusName.active;
          } else if (orderStatusFlag == 2) {
            orderStatusName = OrderStatusName.completed;
          } else {
            orderStatusName = OrderStatusName.cancelled;
          }
          var orderDetails = orderData['order'];
          int orderId = orderDetails['order_id'];
          int hotelId = orderDetails['hotel_id'];
          int supplierId = orderDetails['supplier_id'];
          int tableId = orderDetails['table_id'];
          int orderType = orderDetails['order_type'];
          String deliveryAddress = orderDetails['delivery_address'];
          var rating = orderDetails['rating'];
          bool isRatingGiven = (rating == null) ? false : true;
          double deliveryLat = orderDetails['delivery_lat'];
          double deliveryLon = orderDetails['delivery_lon'];
          double baseAmount = orderDetails['amount'];
          double discount = orderDetails['discount'];
          double tax = orderDetails['tax'];
          double deliveryCharge = orderDetails['delivery_charge'] ?? 0.0;
          double walletUsed = orderDetails['wallet'] ?? 0.0;
          double totalAmount = orderDetails['total'];
          int paymentType = orderDetails['payment_type'];
          int paymentStatus = orderDetails['payment_status'];
          int orderStatus = orderDetails['order_status'];
          String orderStatusDesc = orderData['order_status'];
          String fromLocation = orderData['hotel_name'];
          Color orderStatusColorCode;
          bool isCancelBtnToShow = true;
          switch (orderStatus) {
            case 1:
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = true;
              break;
            case 2:
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = true;
              break;
            case 3:
              orderStatusColorCode = Colors.yellow;
              isCancelBtnToShow = true;
              break;
            case 4:
              orderStatusColorCode = Colors.orange;
              isCancelBtnToShow = true;
              break;
            case 5:
              orderStatusColorCode = Colors.teal;
              isCancelBtnToShow = false;
              break;
            case 6:
              orderStatusColorCode = Colors.green;
              isCancelBtnToShow = false;
              break;
            case 7:
              orderStatusColorCode = Colors.red;
              isCancelBtnToShow = false;
              break;
            default:
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = false;
              break;
          }

          var serverDate = orderDetails['order_date'];
          int deliverySlotId = orderDetails['delivery_slot'];
          String orderDate = changeDateFormat(serverDate);
          var delDate = orderDetails['delivery_time'];
          String deliveryDate = changeDateFormat(delDate);
          String scheduledTime = '';
          if (deliverySlotId > 0) {
            String deliveryDateOnly = changeDateFormatOnlyDate(delDate);
            String slotName = orderData['delivery_slot'];
            scheduledTime = deliveryDateOnly + slotName;
          }
          var orderedItems = orderData['items'];
          String orderTypeDesc = '';
          switch (orderType) {
            case 2:
              orderTypeDesc = 'Door Delivery';
              break;
            case 3:
              orderTypeDesc = 'Door Delivery';
              break;
            case 4:
              orderTypeDesc = 'Door Delivery';
              break;
            default:
              orderTypeDesc = '';
              break;
          }
          List<ProductInOrder> dishes = [];
          String dishesName = '';
          for (var item in orderedItems) {
            int dishId = item['dish_id'];
            String dishName = item['dish_name'];
            String dishIconLink = item['dish_icon'];
            double price = item['rate'];
            String description = item['description'];
            int dishTypeFlag = item['dish_type'];
            double qty = item['qty'];
            int quantity = qty.toInt();
            String hint = dishName + dishName.toLowerCase();
            String grossWeight = item['gross_weight'] ?? '';
            String netWeight = item['net_weight'] ?? '';
            String qtyDescription = 'Gross: $grossWeight';
            if (netWeight != '') {
              qtyDescription = '$qtyDescription  Net: $netWeight';
            }
            double offRate = item['spl_rate'] ?? 0.0;
            String cuttingOptions = item['cuttings'] ?? '';
            bool isCutOptionsAvailable = true;
            String productSizeOption = item['sizes'] ?? '';
            bool isProductSizeOptionsAvailable = true;
            ProductInOrder dishModel = ProductInOrder(
                id: dishId,
                imageLink: dishIconLink,
                name: dishName,
                price: offRate == 0 ? price : offRate,
                count: quantity,
                quantity: '1 Kilo Grams',
                availableStocks: 0,
                isDescriptionShown: false,
                cuttingSize: '',
                description: description,
                qtyDescription: qtyDescription,
                cutOffPrice: offRate == 0 ? 0 : price,
                isCuttingOptionsAvailable: isCutOptionsAvailable,
                cuttingSizeOption: cuttingOptions,
                isItemSizeOptionsAvailable: isProductSizeOptionsAvailable,
                itemSize: '',
                itemSizeOption: productSizeOption,
                grams: 0.0,
                thumbNail: '');
            dishes.add(dishModel);
            if (dishesName == '') {
              dishesName = dishName + ' x ' + quantity.toString();
            } else {
              dishesName =
                  dishesName + ', ' + dishName + ' x ' + quantity.toString();
            }
          }

          Order oM = Order(
              orderId: orderId,
              shopId: hotelId,
              supplierId: supplierId,
              tableId: tableId,
              orderType: orderType,
              deliveryAddress: deliveryAddress,
              deliveryLatitude: deliveryLat,
              deliveryLongitude: deliveryLon,
              amount: baseAmount,
              discount: discount,
              tax: tax,
              totalAmount: totalAmount,
              paymentType: paymentType,
              paymentStatus: paymentStatus,
              orderStatus: orderStatus,
              orderDate: orderDate,
              products: dishes,
              productName: dishesName,
              orderTypeDesc: orderTypeDesc,
              orderStatusColorCode: orderStatusColorCode,
              orderStatusDesc: orderStatusDesc,
              isCancelButtonToShow: isCancelBtnToShow,
              fromLocation: fromLocation,
              deliveryTime: deliveryDate,
              riderId: riderId,
              deliveryCharge: deliveryCharge,
              walletUsed: walletUsed,
              scheduledDeliveryTime: scheduledTime,
              deliverySlotId: deliverySlotId,
              orderStatusName: orderStatusName,
              isRatingsGiven: isRatingGiven);
          orders.add(oM);

          Provider.of<DataServices>(context, listen: false)
              .setActiveOrders(orders);
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: orders);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> notifyOnOutOfStocks({int subCategoryId}) async {
    NetworkResponse responseValue;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt(kUserIdKey);
      var params = new Map<String, dynamic>();
      params['customer_id'] = userId;
      params['dish_id'] = subCategoryId;

      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToNotifyDish, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> applyOrderRatings(
      {int orderId, double ratings}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;
      params['rating'] = ratings;

      var body = json.encode(params);
      http.Response response =
          await http.post(kUrlToApplyRatings, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      print(jsonData);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getDeliveryCharges(
      {int hotelId, String postal, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['hotel_id'] = hotelId;
      params['post_code'] = postal;

      var body = json.encode(params);
      http.Response response = await http.post(kUrlToGetDeliveryCharges,
          headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      print(jsonData);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          double deliveryBarAmount = jsonData['DeliveryBarAmount'] ?? 0.0;
          double defaultExpressFee = jsonData['DefaultExpressFee'] ?? 0.0;
          var responseData = jsonData['Data'];
          double scheduledDeliveryFee = responseData['delivery_fee'] ?? 0.0;
          double expressDeliveryFee = responseData['express_fee'] ?? 0.0;
          int expressDeliveryFlag = jsonData['ShowExpress'] ?? 0;

          DeliveryCharges dC = DeliveryCharges(
              barAmount: deliveryBarAmount,
              defaultExpressDeliveryFee: defaultExpressFee,
              scheduledDeliveryFee: scheduledDeliveryFee,
              expressDeliveryFee: expressDeliveryFee,
              isExpressDeliveryAvailable: expressDeliveryFlag);
          Provider.of<DataServices>(context, listen: false)
              .setDeliveryCharges(dC);
        }
        responseValue = NetworkResponse(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<NetworkResponse> getOffers(
      {double amount, List<int> dishes, BuildContext context}) async {
    NetworkResponse responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['amount'] = amount;
      params['dish_id'] = dishes;

      var body = json.encode(params);
      print(body);
      http.Response response =
          await http.post(kGetOffer, headers: kHeader, body: body);
      String data = response.body;
      var jsonData = jsonDecode(data);
      print(jsonData);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          var responseData = jsonData['Data'];

          List<Product> totalProducts = [];
          for (var product in responseData) {
            int productId = product['dish_id'];
            String productName = product['dish_name'];
            String productIconLink = product['dish_icon'];

            String productDescription = product['description'] ?? '';
            int productTypeFlag = product['dish_type'];
            int availableNoOfStock = product['dish_stocks'];
            String productThumbnail = product['dish_thumbnail'];
            if (productThumbnail.endsWith('/')) {
              productThumbnail = productIconLink;
            }
            int gstPercentage = product['gst'] ?? 0;
            int productGramsQtyInInt = product['grams'] ?? 0;
            double productGramsQtyInDouble = productGramsQtyInInt.toDouble();
            String productGrossWeight = product['gross_weight'] ?? '';
            String productNetWeight = product['net_weight'] ?? '';
            String productQtyDescription = 'Gross: $productGrossWeight';
            if (productNetWeight != '') {
              productQtyDescription =
                  '$productQtyDescription  Net: $productNetWeight';
            }
            //int cuttingOption = dish['slice_opt'] ?? 0;
            double productPrice = product['rate'];
            double productOffRate = product['spl_rate'] ?? 0.0;

            List<dynamic> cuttingOptionsDynamic = product['cuttings'];
            List<String> cuttingOptions = [];
            for (var c in cuttingOptionsDynamic) {
              cuttingOptions.add('$c');
            }
            bool isCutOptionsAvailable =
                (cuttingOptions.length > 0) ? true : false;
            List<dynamic> productSizeOptionDynamic = product['sizes'];
            List<String> productSizeOption = [];
            for (var p in productSizeOptionDynamic) {
              productSizeOption.add('$p');
            }
            bool isProductSizeOptionsAvailable =
                (productSizeOption.length > 0) ? true : false;

            Product productModel = Product(
                id: productId,
                imageLink: productIconLink,
                name: productName,
                price: productOffRate == 0 ? productPrice : productOffRate,
                quantity: '1 KiloGrams',
                count: 0,
                availableStocks: availableNoOfStock,
                isDescriptionShown: false,
                cuttingSize: '',
                description: productDescription,
                qtyDescription: productQtyDescription,
                cutOffPrice: productOffRate == 0 ? 0 : productPrice,
                isCuttingOptionsAvailable: isCutOptionsAvailable,
                cuttingSizeOptions: cuttingOptions,
                isItemSizeOptionsAvailable: isProductSizeOptionsAvailable,
                itemSizeOptions: productSizeOption,
                itemSize: '',
                grams: productGramsQtyInDouble,
                thumbNail: productThumbnail,
                gstPercentage: gstPercentage,
                offerFlag: 1);
            print(productModel);
            totalProducts.add(productModel);
          }
          responseValue = NetworkResponse(
              code: responseCode,
              message: responseMessage,
              data: totalProducts);
        } else {
          responseValue = NetworkResponse(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = NetworkResponse(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = NetworkResponse(code: 0, message: err, data: null);
    }
    return responseValue;
  }
}
