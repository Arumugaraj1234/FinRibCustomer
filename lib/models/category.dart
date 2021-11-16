import 'package:finandrib/models/product.dart';
import 'package:finandrib/models/sub_category.dart';

class Category {
  int id;
  String name;
  String image;
  List<SubCategory> subCategories;

  Category({this.id, this.name, this.image, this.subCategories});

  Map<String, dynamic> toJson() => {
        'categoryId': id,
        'categoryName': name,
        'categoryImageLink': image,
        'subCategories': subCategories,
      };

  bool get isSubCategoryAvailable => subCategories.length > 0 ? true : false;
}
