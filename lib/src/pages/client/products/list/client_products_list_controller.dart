import 'dart:async';

import 'package:delivery_alex_salcedo/src/models/category.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:delivery_alex_salcedo/src/provider/categories_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/products_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientProductsListController {
  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;
  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  ProductsProvider _productsProvider = new ProductsProvider();
  List<Category> categories = [];

  Timer searchOnStoppedTyping;

  String productName = '';

  //PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    //Se carga la sesión del usuario almacenada en la SharedPreferences
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, user);
    _productsProvider.init(context, user);
    getCategories();
    //Actualizar la página
    refresh();
  }

  Future<List<Product>> getProductsByCategory(
      String idCategory, String productName) async {
    if (productName.isEmpty) {
      // Traer los productos por categoría
      return await _productsProvider.getProductsByCategory(idCategory);
    } else {
      return await _productsProvider.getByCategoryAndProductName(
          idCategory, productName);
    }
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh();
  }

  void logout() {
    _sharedPref.logout(context, user.id);
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }

  void goToUpdatePage() {
    Navigator.pushNamed(context, 'client/update');
  }

  void openBottomSheet(Product product) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ClientProductsDetailPage(product: product));
  }

  void goToOrderCreatePage() {
    Navigator.pushNamed(context, 'client/orders/create');
  }

  void goToOrdersListPage() {
    Navigator.pushNamed(context, 'client/orders/list');
  }

  void onChangeText(String text) {
    const duration = Duration(
        milliseconds:
            800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel();
      refresh();
    }

    searchOnStoppedTyping = new Timer(duration, () {
      productName = text;
      refresh();
      // getProducts(idCategory, text)
      print('TEXTO COMPLETO $text');
    });
  }
}
