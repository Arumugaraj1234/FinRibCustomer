import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

double kCurrentVersion = 2.0;

//MARK:- HEADERS
const kHeader = {"Content-Type": "application/json"};

// MARK: URL CONSTANTS
const kBaseUrl = 'http://finnribapi.azurewebsites.net//api/Customer/';
const kUrlToGetInitSettings = kBaseUrl + 'Init';
const kUrlToGetAllShops = kBaseUrl + 'GetHotels';
const kUrlToGetProductByShop = kBaseUrl + 'GetDishesByHotel';
const kUrlToRequestOtp = kBaseUrl + 'RequestOTP';
const kUrlToRegisterNewUser = kBaseUrl + 'Register';
const kUrlToOtpVerification = kBaseUrl + 'VerifyOTP';
const kUrlToLoginWithPassword = kBaseUrl + 'Login';
const kUrlToChangeThePassword = kBaseUrl + 'ChangePassword';
const kUrlToGetAllAddress = kBaseUrl + 'GetFavAddress';
const kUrlToAddOrDeleteAddress = kBaseUrl + 'AddRemoveFavAddress';
const kUrlToGetCustomerInfo = kBaseUrl + 'GetCustomerInfo';
const kUrlToApplyPromoCode = kBaseUrl + 'ApplyCode';
const kUrlToSaveOrder = kBaseUrl + 'PlaceOrder';
const kUrlToScratchReward = kBaseUrl + 'ScratchCard';
const kUrlToGetAllRewards = kBaseUrl + 'GetMyCards';
const kUrlToRedeemReferralCode = kBaseUrl + 'Redeem';
const kUrlToGetOrdersHistory = kBaseUrl + 'MyOrders';
const kUrlToCancelOrder = kBaseUrl + 'CancelOrder';
const kUrlToUpdateProfileDetails = kBaseUrl + 'UpdateProfile';
const kUrlToVerifyOtpToResetMobileNo = kBaseUrl + 'ChangePhoneVerify';
const kUrlToTrackRider = kBaseUrl + 'TrackRider';
const kUrlToTrackOrder = kBaseUrl + 'TrackOrder';
const kUrlToUpdatePaymentStatus = kBaseUrl + 'UpdatePayment';
const kUrlToRemoveOrderFromHistory = kBaseUrl + 'RemoveFromHistory';
const kUrlToGetTimeSlot = kBaseUrl + 'GetTimeSlot';
const kUrlToCheckForLiveOrder = kBaseUrl + 'ActiveOrder';
const kUrlToNotifyDish = kBaseUrl + 'NotifyDish';
const kUrlToApplyRatings = kBaseUrl + 'ApplyRating';
const kUrlToGetDeliveryCharges = kBaseUrl + 'GetDeliveryFee';

const karkblueish = Color(0xFF041f54);
String kMoneySymbol = '${String.fromCharCodes(new Runes('\u20B9'))}';

//MARK:- TEXT STYLES
const kTextStyleAppBarTitle =
    TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.bold);
const kTextStyleTitle = TextStyle(
    color: Colors.deepOrange,
    fontWeight: FontWeight.bold,
    fontFamily: 'Calibri',
    fontSize: 16);
const kTextStyleCardTitle =
    TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Calibri', fontSize: 15);
const kTextStyleCalibriBold =
    TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.bold);
const kTextStyleCalibri600 =
    TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w600);
const kTextStyleCalibri300 =
    TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w400);
const kTextStyleButton = TextStyle(
    fontFamily: 'Calibri',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16);

//MARK: SHARED PREFERENCES KEYS CONSTANT
const kUserLoggedInKey = 'userLoggedInStatus';
const kUserIdKey = 'userId';
const kUserDetailsKey = 'userDetails';
const kReferralCodeKey = 'referralCode';
