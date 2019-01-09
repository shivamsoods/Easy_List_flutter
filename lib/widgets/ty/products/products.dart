  import 'package:flutter/material.dart';

  import 'package:flutter_course/widgets/ty/products/product_card.dart';
  import 'package:flutter_course/scoped_models/products.dart';
  import 'package:flutter_course/models/product.dart';

  import 'package:scoped_model/scoped_model.dart';

  class Products extends StatelessWidget {

    Widget _buildProductList(List<Product> products, BuildContext context) {
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
      print('product card just before returning main page list');
      return productCards;
    }

    @override
    Widget build(BuildContext context) {
      print('[Products Widget] build()');

  //    return ScopedModelDescendant<ProductsModel>(
  //      builder: (BuildContext context,Widget child,ProductsModel model) {
  //        return _buildProductList(model.products);
  //      },
  //    );

  //    return ScopedModel<ProductsModel>(
  //      model: ProductsModel(),
  //      child: Column(
  //        children: <Widget>[
  //          Text('list upper'),
  //          ScopedModelDescendant<ProductsModel>(builder:
  //              (BuildContext context, Widget child, ProductsModel model) {
  //            print('product in p/p.d ' + model.products.toString());
  //            return _buildProductList(model.products, context);
  //          }),
  //        ],
  //      ),
  //    );

    return ScopedModel<ProductsModel>(model: ProductsModel(),child: ScopedModelDescendant(builder: (BuildContext context,Widget child,ProductsModel model){
      print('building list '+model.products.toString());
      return  _buildProductList(model.products, context);
    }),);
    }
  }
