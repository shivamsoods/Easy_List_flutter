import 'package:flutter/material.dart';

import 'package:flutter_course/widgets/ty/products/product_card.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/models/product.dart';

import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(products[index], index, context);
        },
        itemCount: products.length,
      );
    } else {
      productCards = Container(child: Text('List is empty  bro!'));
    }
    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');

        return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context,Widget child,MainModel model) {
            return _buildProductList(model.displayedProducts);
          },
        );


  }
}
