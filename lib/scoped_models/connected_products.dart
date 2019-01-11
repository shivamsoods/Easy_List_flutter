import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';

class ConnectedProductsModel extends Model{
  List<Product> _products = [];
  User _authenticatedUser;
  int  _selProductIndex;

  void addProduct(String title,String description String image,double price) {

    final Product newProduct= Product(title: title, description: description, image: image,price: price,userEmail: _authenticatedUser.email,userId: _authenticatedUser.id);
  _products.add(newProduct);
  notifyListeners();
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



  void updateProduct(String title,String description String image,double price) {
  final Product updatedProduct= Product(title: title,
  description: description,
  image: image,
  price: price,
  userEmail: selectedProduct.userEmail,
  userId: selectedProduct.userId);
  _products[selectedProductIndex] = updatedProduct;

  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);

  }

  void selectProduct(int index) {
    _selProductIndex = index;
    notifyListeners();
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;

    final Product updatedProduct = Product(
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
    if (selectedProductIndex == null) {
      return null;
    }
    return _products[selectedProductIndex];
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel{

  void login(String email,String password){
    _authenticatedUser=User(id:  'sad', email: email, password:password);
  }
}
