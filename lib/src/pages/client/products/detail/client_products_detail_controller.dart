import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientProductsDetailController {
  BuildContext context;
  Function refresh;
  Product product;
  int counter = 1;
  double productPrice;
  SharedPref _sharedPref = new SharedPref();
  List<Product> selectedProducts = [];

  Future init(BuildContext context, Function refresh, Product product) async {
    this.context = context;
    this.refresh = refresh;
    this.product = product;
    productPrice = product.price;

    // Para dejar la orden vacía
    //_sharedPref.remove('order');

    // Leer los productos agregados anteriormente
    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;

    selectedProducts.forEach((p) {
      print('Producto seleccionado: ${p.toJson()}');
    });
    refresh();
  }

  void addItem() {
    counter++;
    productPrice = product.price * counter;
    product.quantity = counter;
    refresh();
  }

  void removeItem() {
    if (counter > 1) {
      counter = counter - 1;
      productPrice = product.price * counter;
      product.quantity = counter;
      refresh();
    }
  }

  void addToBag() {
    // Para saber si un producto existe dentro de la lista de los productos seleccionados
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      // No existe elproducto
      if (product.quantity == null) {
        product.quantity = 1;
      }
      selectedProducts.add(product);
    } else {
      // Producto ya existe en la lista
      selectedProducts[index].quantity = counter;
    }

    _sharedPref.save('order', selectedProducts);
    Fluttertoast.showToast(msg: 'Producto agregado correctamente');
  }

  void close() {
    Navigator.pop(context);
  }
}
