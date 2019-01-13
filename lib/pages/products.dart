import 'package:flutter/material.dart';

import 'package:flutter_course/widgets/ty/products/products.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/ty/ui_elements/logout_list_tile.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;
  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {

    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage>{
    @override
    initState(){
      widget.model.fetchProducts();
      super.initState();
    }


  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }

  Widget _buildProductsList(){
      return ScopedModelDescendant<MainModel>(builder: (BuildContext context,Widget child,MainModel model){
        Widget content=Center(child:Text('No products found'));
        if(model.displayedProducts.length>0 &&  !model.isLoading){
           content=Products();
        }
        else if (model.isLoading){
             content =Center(child:CircularProgressIndicator());
        }
        return RefreshIndicator(child: content,onRefresh: model.fetchProducts,);
      },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavouritesOnly?Icons.favorite:Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: _buildProductsList(),
    );
  }
}
