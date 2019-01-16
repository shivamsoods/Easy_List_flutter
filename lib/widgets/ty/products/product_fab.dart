import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFAB extends StatefulWidget {
  final Product product;

  ProductFAB(this.product);
  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(microseconds: 300));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                height: 50,
                width: 60,
                alignment: FractionalOffset.topCenter,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).cardColor,
                    mini: true,
                    heroTag: 'contact',
                    onPressed: () async {
                      final url = 'mailto:${widget.product.userEmail}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    child: Icon(
                      Icons.mail,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )),
            Container(
              height: 60,
              width: 60,
              alignment: FractionalOffset.topCenter,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                mini: true,
                onPressed: () {
                  model.toggleProductFavouriteStatus();
                },
                heroTag: 'favourite',
                child: Icon(
                    model.selectedProduct.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red),
              ),
            ),
            Container(
              child: FloatingActionButton(
                heroTag: 'options',
                onPressed: () {
                  if(_controller.isDismissed){
                    _controller.forward();
                  }
                  else{
                    _controller.reverse();
                  }
                },
                child: Icon(Icons.more_vert),
              ),
            ),
          ],
        );
      },
    );
  }
}
