import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart'as http;
import 'package:flutter_course/models/auth.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;

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

  Future<bool> addProduct(String title, String description,String image,double price) async {
    _isLoading=true;
    notifyListeners();

    final Map<String, dynamic> productData={
      'title':title,
      'description':description,
      'image':'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnaB5OgTv7gLFsVgGHqrJDW8BhWJiiFoJZutVXXKPGM-s0cXCZ',
      'price':price, 'userId': _authenticatedUser.id, 'userEmail':_authenticatedUser.email
    };


    try{
      final http.Response response=await http.post('https://flutter-course-443f7.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body:json.encode(productData));


      if(response.statusCode!=200 && response.statusCode!=201){
        _isLoading=false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData=json.decode(response.body);
      final Product newProduct= Product(id:responseData['name'], title: title, description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      notifyListeners();
      return true;
    }
    catch(error){
      _isLoading=false;
      notifyListeners();
      return false;

    }
  }


  Future<bool> updateProduct(String title,String description String image,double price) {
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
   return http.put('https://flutter-course-443f7.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
  body: json.encode(updateData))
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
return true;
  })
      .catchError((error){
  _isLoading=false;
  notifyListeners();
  return false;
  });



  }

  Future<bool> deleteProduct() {
    _isLoading=true;
    final deletedProductId=selectedProduct.id;


    _products.removeAt(selectedProductIndex);
    _selProductId=null;
    notifyListeners();
    return http.delete('https://flutter-course-443f7.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response){
          _isLoading=false;
          notifyListeners();
          return true;
    })
    .catchError((error){
      _isLoading=false;
      notifyListeners();
      return false;
    }) ;

  }

  Future<Null> fetchProducts(){
    _isLoading=true;
    notifyListeners();
    return http
        .get('https://flutter-course-443f7.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>( (http.Response response){


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
_selProductId=null;
    })
    .catchError((error){
      _isLoading=false;
      notifyListeners();
      return ;
    });



  }
  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  String get selectedProductId {
    return _selProductId;
  }

  void toggleProductFavouriteStatus() async{
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
     http.Response response;
    if(newFavouriteStatus){
       response = await http.put('https://flutter-course-443f7.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?=auth=${_authenticatedUser.token}',
      body: json.encode(true));
    }
    else{
      response=await http.delete('https://flutter-course-443f7.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?=auth=${_authenticatedUser.token}');
    }


    if(response.statusCode !=200&&response.statusCode !=201 ){
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavourite: !newFavouriteStatus);

      _products[selectedProductIndex] = updatedProduct;

      notifyListeners();
    }

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
  Timer _authTimer;

  PublishSubject<bool>_userSubject=PublishSubject();

  PublishSubject<bool> get userSubject{
    return _userSubject;
  }


  User get user {return _authenticatedUser;}

  Future<Map<String,dynamic>> authenticate(String email,String password,[AuthMode mode=AuthMode.Login]) async{
    _isLoading=true;
    notifyListeners();
    final Map<String,dynamic> authData={
      'email':email,
      'password':password,
      'returnSecureToken':true
    };
    http.Response response;
    if(mode==AuthMode.Login){
      response=await http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCheyrnUDFgup8teL7nNjpHfPcIzknRRr0',
          body: json.encode(authData),
          headers:{'Content-Type':'application/json'});
    }
    else{

      response=await  http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCheyrnUDFgup8teL7nNjpHfPcIzknRRr0',
          body: json.encode(authData),
          headers:{'Content-Type':'application/json'});
    }




    final Map<String,dynamic> responseData= json.decode(response.body);
    bool hasError=true;
    String message='Something went wrong';
    if(responseData.containsKey('idToken')){
      hasError=false;
      message='Authentication success!';
      _authenticatedUser=User(id: responseData['localId'], email: email, token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);


      final DateTime now = DateTime.now();
      final DateTime expiryTime =  now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs =await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail',email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String() );



    }
    else if(responseData['error']['message']=='EMAIL_NOT_FOUND'){
      message=' $email not found';
    }
    else if(responseData['error']['message']=='INVALID_PASSWORD'){
      message=' Invalid Password';
    }
    else if(responseData['error']['message']=='EMAIL_EXISTS'){
      message=' $email already exists';
    }
    else{
      message='Something went wrong';
    }
    _isLoading=false;
    notifyListeners();
    return {
      'success':!hasError,
      'message':message
    };

    }

    void autoAuthenticate()async{
     final SharedPreferences prefs=await  SharedPreferences.getInstance();
     final String token =  prefs.getString('token');
     final String expiryTimeString=prefs.getString('expiryTime');

     if(token!=null){
       final DateTime now=DateTime.now();
       final parsedExpiryTime=DateTime.parse(expiryTimeString);
       if(parsedExpiryTime.isBefore(now)){
         _authenticatedUser=null;
         notifyListeners();
         return;
       }
       final String userEmail=prefs.getString('userEmail');
       final String userId=prefs.getString('userId');
       final int tokenLifeSpan= parsedExpiryTime.difference(now).inSeconds;
       _authenticatedUser=User(id: userId, email: userEmail, token: token);
       _userSubject.add(true);
       setAuthTimeout(tokenLifeSpan);
       notifyListeners();
     }
    }

    void logout()async{
    _authenticatedUser=null;
    _authTimer.cancel();
    _userSubject.add(false);

    final SharedPreferences prefs=await  SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

    void setAuthTimeout(int time){
    _authTimer=Timer(Duration(seconds: time),(){
      logout();
    });

    }

}

class UtilityModel extends ConnectedProductsModel{
  bool get isLoading{
    return _isLoading;
  }
}
