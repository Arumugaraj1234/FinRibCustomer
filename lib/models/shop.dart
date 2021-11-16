class Shop {
  int id;
  String name;
  String address;
  List<String> pinCodes;
  int flag;
  String remarks;
  bool isAdvImageToShow;
  String advImageUrl;
  double deliveryCharge;

  Shop(
      {this.id,
      this.name,
      this.address,
      this.pinCodes,
      this.flag,
      this.remarks,
      this.isAdvImageToShow,
      this.advImageUrl,
      this.deliveryCharge});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'pincodes': pinCodes,
        'flag': flag,
        'remarks': remarks,
        'isAdvImageToShow': isAdvImageToShow,
        'advImageUrl': advImageUrl
      };
}
