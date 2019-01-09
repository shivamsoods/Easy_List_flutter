import 'package:flutter/material.dart';

import 'package:flutter_course/models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_course/scoped_models/products.dart';

class ProductEditPage extends StatefulWidget {
  final Function addProduct;
  final Function updateProduct;
  final Product product;
  final int productIndex;

  ProductEditPage(
      {this.addProduct, this.updateProduct, this.product, this.productIndex});

  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Title'),
      initialValue: widget.product == null ? '' : widget.product.title,
      validator: (String value) {
        // if (value.trim().length <= 0) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Product Description'),
      initialValue: widget.product == null ? '' : widget.product.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Product Price'),
      initialValue:
          widget.product == null ? '' : widget.product.price.toString(),
      validator: (String value) {
        // if (value.trim().length <= 0) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ScopedModelDescendant<ProductsModel>(
      builder:(context,child,model) {
        return RaisedButton(
          child: Text('Save'),
          textColor: Colors.white,
          onPressed: ()=>_submitForm(model.addProduct,model.updateProduct) ,
        );
      },
    );

//    return ScopedModel<ProductsModel>(
//      model: ProductsModel(),
//      child: Column(
//        children: <Widget>[
//          Text('uppper text'),
//          ScopedModelDescendant<ProductsModel>(builder:
//              (BuildContext context, Widget child, ProductsModel model) {
//            return RaisedButton(
//              child: Text('Save'),
//              textColor: Colors.white,
//              onPressed: () {
//                _submitForm(model.addProduct, model.updateProduct);
//
//                print('saving button  ' + model.products.toString());
//              },
//            );
//          })
//        ],
//      ),
//    );

  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(),
              _buildDescriptionTextField(),
              _buildPriceTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(Function addProduct, Function updateProduct) {
    print('submit form reached');

    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    if (widget.product == null) {
      print('there is no product and it is adding');
      addProduct(Product(
          title: _formData['title'],
          description: _formData['description'],
          price: _formData['price'],
          image: _formData['image']));
    }
    else {
      updateProduct(
          widget.productIndex,
          Product(
              title: _formData['title'],
              description: _formData['description'],
              price: _formData['price'],
              image: _formData['image']));
    }

    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    final Widget pageContent = _buildPageContent(context);

    return widget.product == null
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Product'),
            ),
            body: pageContent,
          );
  }
}
