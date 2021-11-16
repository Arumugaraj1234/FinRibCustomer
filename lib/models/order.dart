import 'package:finandrib/models/product.dart';
import 'package:flutter/cupertino.dart';

enum OrderStatusName { active, completed, cancelled }

class Order {
  int orderId;
  int shopId;
  int supplierId;
  int tableId;
  int orderType;
  String orderTypeDesc;
  String deliveryAddress;
  double deliveryLatitude;
  double deliveryLongitude;
  double amount;
  double discount;
  double tax;
  double totalAmount;
  int paymentType;
  int paymentStatus;
  int orderStatus;
  String orderStatusDesc;
  Color orderStatusColorCode;
  String orderDate;
  List<ProductInOrder> products;
  String productName;
  bool isCancelButtonToShow;
  String fromLocation;
  String deliveryTime;
  int riderId;
  double deliveryCharge;
  double walletUsed;
  String scheduledDeliveryTime;
  int deliverySlotId;
  OrderStatusName orderStatusName;
  bool isRatingsGiven;

  Order(
      {this.orderId,
      this.shopId,
      this.supplierId,
      this.tableId,
      this.orderType,
      this.deliveryAddress,
      this.deliveryLatitude,
      this.deliveryLongitude,
      this.amount,
      this.discount,
      this.tax,
      this.totalAmount,
      this.paymentType,
      this.paymentStatus,
      this.orderStatus,
      this.orderDate,
      this.products,
      this.productName,
      this.orderTypeDesc,
      this.orderStatusColorCode,
      this.orderStatusDesc,
      this.isCancelButtonToShow,
      this.fromLocation,
      this.deliveryTime,
      this.riderId,
      this.deliveryCharge,
      this.walletUsed,
      this.scheduledDeliveryTime,
      this.deliverySlotId,
      this.orderStatusName,
      this.isRatingsGiven});
}

class OrderStatusModel {
  int orderId;
  String fromLocation;
  String deliveryLocation;
  int status;
  String statusDesc;

  OrderStatusModel(
      {this.orderId,
      this.fromLocation,
      this.deliveryLocation,
      this.status,
      this.statusDesc});
}
