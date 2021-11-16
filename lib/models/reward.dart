class Reward {
  final int id;
  final int orderId;
  bool isScratched;
  final String orderDate;
  final double amount;

  Reward(
      {this.id, this.orderId, this.isScratched, this.orderDate, this.amount});
}
