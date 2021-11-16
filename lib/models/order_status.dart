class OrderStatus {
  String name;
  String time;
  TickStatus status;

  OrderStatus({this.name, this.time, this.status});
}

enum TickStatus { selected, unselected }
