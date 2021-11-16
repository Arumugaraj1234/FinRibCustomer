import 'package:finandrib/models/product.dart';

class SubCategory {
  int id;
  String name;
  String iconImageLink;
  String thumbnail;
  String quantity;
  double originalPrice;
  double discountPrice;
  List<Product> products;
  int availableStocks;

  SubCategory(
      {this.id,
      this.name,
      this.iconImageLink,
      this.thumbnail,
      this.quantity,
      this.originalPrice,
      this.discountPrice,
      this.products,
      this.availableStocks});

  String offPercentage() {
    double off = 0;
    if (discountPrice != 0) {
      off = ((discountPrice - originalPrice) / discountPrice) * 100;
    }
    return off.toStringAsFixed(0);
  }
}
