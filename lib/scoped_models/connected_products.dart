import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart'as http;

class ConnectedProductsModel extends Model{
  List<Product> _products = [];
  User _authenticatedUser;
  String  _selProductId;
  bool _isLoading=false;

  Future<Null> addProduct(String title,String description String image,double price) {
    _isLoading=true;
    notifyListeners();

    final Map<String,dynamic> productData={'title':title,
    'description':description,
    'image':'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnaB5OgTv7gLFsVgGHqrJDW8BhWJiiFoJZutVXXKPGM-s0cXCZ',
    'price':price,'userId': _authenticatedUser.id,'userEmail':_authenticatedUser.email};

    return http.post('https://flutter-course-443f7.firebaseio.com/products.json',body:json.encode(productData)).then((http.Response response){

      _isLoading=false;
      final Map<String,dynamic> responseData=json.decode(response.body);


  final Product newProduct= Product(id:responseData['name'],title: title, description: description,
  image: image,
  price: price,
  userEmail: _authenticatedUser.email,
  userId: _authenticatedUser.id);
  _products.add(newProduct);
  notifyListeners();
  });


  }
}

class ProductsModel extends ConnectedProductsModel{


  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return List.from(_products.where((Product product) {
        return product.isFavourite;
      }).toList());
    }
    return List.from(_products);
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  int get  selectedProductIndex{
    return _products.indexWhere((Product product){
    return product.id==_selProductId;
  });
  }



  Future<Null> updateProduct(String title,String description String image,double price) {
    _isLoading=true;
    notifyListeners();

    Map<String,dynamic> updateData={
      'title':title,
      'description':description,
      'image':'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnaB5OgTv7gLFsVgGHqrJDW8BhWJiiFoJZutVXXKPGM-s0cXCZ',
      'price':price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
  };
   return http.put('https://flutter-course-443f7.firebaseio.com/products/${selectedProduct.id}.json',body: json.encode(updateData))
      .then((http.Response response){
        _isLoading=false;

        final Product updatedProduct= Product(
  id:selectedProduct.id,
  title: title,
  description: description,
  image: image,
  price: price,
  userEmail: selectedProduct.userEmail,
  userId: selectedProduct.userId);

        final int selectedProductIndex= _products.indexWhere((Product product){
          return product.id==_selProductId;
  });


  _products[selectedProductIndex] = updatedProduct;
  notifyListeners();

  });



  }

  void deleteProduct() {
    _isLoading=true;
    final deletedProductId=selectedProduct.id;


    _products.removeAt(selectedProductIndex);
    _selProductId=null;
    notifyListeners();
    http.delete('https://flutter-course-443f7.firebaseio.com/products/$deletedProductId.json')
        .then((http.Response response){
          _isLoading=false;
          notifyListeners();
    });

  }

  Future<Null> fetchProducts(){
    _isLoading=true;
    notifyListeners();
    return http
        .get('https://flutter-course-443f7.firebaseio.com/products.json')
        .then( (http.Response response){


        final List<Product> fetchedProductList=[];

      final Map<String,dynamic> productListData=json.decode(response.body);

      if(productListData==null){
        _isLoading=false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData){
        final Product product=  Product(
            id:productId
            ,title: productData['title']
            , description:productData['description']
            , image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);

        fetchedProductList.add(product);
      });
_products=fetchedProductList;
        _isLoading=false;
notifyListeners();
    });


  }
  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  String get selectedProductId {
    return _selProductId;
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;

    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus);

    _products[selectedProductIndex] = updatedProduct;

    notifyListeners();
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product){
      return product.id==_selProductId;
    });
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel{

  void login(String email,String password){
    _authenticatedUser=User(id:'sad', email: email, password:password);
  }
}

class UtilityModel extends ConnectedProductsModel{
  bool get isLoading{
    return _isLoading;
  }
}
