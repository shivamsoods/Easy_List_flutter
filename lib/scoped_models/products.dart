import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/models/product.dart';

class ProductsModel extends Model {

  static ProductsModel of(BuildContext context)=>ScopedModel.of<ProductsModel>(context);

  List<Product> _products = [];

  List<Product> get products {
    return List.from(_products);
//      return _products;
  }


  void addProduct(Product product) {
    _products.add(product);
//    print('added a product');
  }

  void updateProduct(int index, Product product) {
    _products[index] = product;
  }

  void deleteProduct(int index) {
    _products.removeAt(index);
  }
}
