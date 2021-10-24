import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:flutter/material.dart';

class ClientProductsDetailController {
  BuildContext context;
  Function refresh;
  Product product;

  Future init(BuildContext context, Function refresh, Product product) {
    this.context = context;
    this.refresh = refresh;
    this.product = product;
    refresh();
  }
}
