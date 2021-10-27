import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientOrdersCreateController {
  BuildContext context;
  Function refresh;
  Product product;
  int counter = 1;
  double productPrice;
  SharedPref _sharedPref = new SharedPref();
  List<Product> selectedProducts = [];
  double total = 0;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Leer la orden almacenada en cache
    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;

    getTotal();
    refresh();
  }

  void getTotal() {
    total = 0;
    selectedProducts.forEach((product) {
      total = total + (product.price * product.quantity);
    });
    refresh();
  }

  void addItem(Product product) {
    // Para saber que producto estamos modificando
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts[index].quantity = selectedProducts[index].quantity + 1;
    _sharedPref.save('order', selectedProducts);
    // Para que se reclacule el valor a pagar
    getTotal();
  }

  void removeItem(Product product) {
    // Validar para que se resten productos siempre y cuando haya al menos un producto seleccionado
    if (product.quantity > 1) {
      // Para saber que producto estamos modificando
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      selectedProducts[index].quantity = selectedProducts[index].quantity - 1;
      _sharedPref.save('order', selectedProducts);
      // Para que se reclacule el valor a pagar
      getTotal();
    }
  }

  void deleteItem(Product product) {
    // Eliminamos el producto de la lista
    selectedProducts.removeWhere((p) => p.id == product.id);
    _sharedPref.save('order', selectedProducts);
    getTotal();
  }

  void goToAddress() {
    Navigator.pushNamed(context, 'client/address/list');
  }
}
