class Product {
  int id;
  String imageLink;
  String name;
  double price;
  int count = 0;
  String quantity;
  int availableStocks;
  bool isDescriptionShown = false;
  String cuttingSize;
  String description;
  String qtyDescription;
  double cutOffPrice;
  bool isCuttingOptionsAvailable;
  List<String> cuttingSizeOptions;
  String itemSize;
  List<String> itemSizeOptions;
  bool isItemSizeOptionsAvailable;
  double grams;
  String thumbNail;
  int gstPercentage;

  Product(
      {this.id,
      this.imageLink,
      this.name,
      this.price,
      this.quantity,
      this.count,
      this.availableStocks,
      this.isDescriptionShown,
      this.cuttingSize,
      this.description,
      this.qtyDescription,
      this.cutOffPrice,
      this.isCuttingOptionsAvailable,
      this.cuttingSizeOptions,
      this.itemSize,
      this.itemSizeOptions,
      this.isItemSizeOptionsAvailable,
      this.grams,
      this.thumbNail,
      this.gstPercentage});

  double get totalPrice => price * count;

  double gstAmount() {
    double a = price * (gstPercentage * 0.01) * count;
    double b = double.parse((a).toStringAsFixed(2));
    return b;
  }

  String offPercentage() {
    double off = 0;
    if (cutOffPrice != 0) {
      off = ((cutOffPrice - price) / cutOffPrice) * 100;
    }
    return off.toStringAsFixed(0);
  }

  double productGrams() {
    if (grams > 999) {
      double value = grams / 1000;
      return value;
    }
    return grams;
  }

  String initialUom() {
    if (grams > 999) {
      return 'Kg';
    }
    return 'Grams';
  }

  double totalGrams() {
    double totalGrams = count * grams;
    if (totalGrams > 999) {
      double returnValue = totalGrams / 1000;
      return returnValue;
    }
    return totalGrams;
  }

  String unitOfMeasurement() {
    double totalGrams = count * grams;

    if (totalGrams > 999) {
      return "Kg";
    }
    return "Grams";
  }
}

class ProductInOrder {
  int id;
  String imageLink;
  String name;
  double price;
  int count = 0;
  String quantity;
  int availableStocks;
  bool isDescriptionShown = false;
  String cuttingSize;
  String description;
  String qtyDescription;
  double cutOffPrice;
  bool isCuttingOptionsAvailable;
  String cuttingSizeOption;
  String itemSize;
  String itemSizeOption;
  bool isItemSizeOptionsAvailable;
  double grams;
  String thumbNail;

  ProductInOrder(
      {this.id,
      this.imageLink,
      this.name,
      this.price,
      this.quantity,
      this.count,
      this.availableStocks,
      this.isDescriptionShown,
      this.cuttingSize,
      this.description,
      this.qtyDescription,
      this.cutOffPrice,
      this.isCuttingOptionsAvailable,
      this.cuttingSizeOption,
      this.itemSize,
      this.itemSizeOption,
      this.isItemSizeOptionsAvailable,
      this.grams,
      this.thumbNail});

  double get totalPrice => price * count;

  String offPercentage() {
    double off = 0;
    if (cutOffPrice != 0 && cutOffPrice != price) {
      off = ((cutOffPrice - price) / cutOffPrice) * 100;
    }
    return off.toStringAsFixed(0);
  }

  double productGrams() {
    if (grams > 999) {
      double value = grams / 1000;
      return value;
    }
    return grams;
  }

  String initialUom() {
    if (grams > 999) {
      return 'Kg';
    }
    return 'Grams';
  }

  double totalGrams() {
    double totalGrams = count * grams;
    if (totalGrams > 999) {
      double returnValue = totalGrams / 1000;
      return returnValue;
    }
    return totalGrams;
  }

  String unitOfMeasurement() {
    double totalGrams = count * grams;

    if (totalGrams > 999) {
      return "Kg";
    }
    return "Grams";
  }
}
