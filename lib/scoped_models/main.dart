import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/scoped_models/connected_products.dart';

// ignore: mixin_inherits_from_not_object
class MainModel extends Model with ConnectedProductsModel,UserModel,ProductsModel,UtilityModel{


}