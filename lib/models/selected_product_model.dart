class SelectedProduct {
  int dish_id;
  int qty;
  String cutSize;
  String itemSize;

  SelectedProduct({this.dish_id, this.qty, this.cutSize, this.itemSize});

  SelectedProduct.fromJson(Map<String, dynamic> json)
      : dish_id = json['dish_id'],
        qty = json['qty'],
        cutSize = json['cutSize'],
        itemSize = json['itemSize'];

  Map<String, dynamic> toJson() => {
        'dish_id': dish_id,
        'qty': qty,
        'dish_size': itemSize,
        'dish_cutting': cutSize
      };
}
