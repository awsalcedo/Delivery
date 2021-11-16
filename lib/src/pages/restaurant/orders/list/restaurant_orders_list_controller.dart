import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/pages/restaurant/orders/detail/restaurant_orders_detail_page.dart';
import 'package:delivery_alex_salcedo/src/provider/orders_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RestaurantOrdersListController {
  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;
  List<String> status = ['PAGADO', 'DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  bool isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    // Inicializar provider
    _ordersProvider.init(context, user);
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

  void goToCategoryCreate() {
    Navigator.pushNamed(context, 'restaurant/categories/create');
  }

  void goToProductCreate() {
    Navigator.pushNamed(context, 'restaurant/products/create');
  }

  Future<List<Order>> getOrders(String status) async {
    return await _ordersProvider.getByStatus(status);
  }

  void openDetailOrderBottomSheet(Order order) async {
    // Para saber si existió una actualización

    isUpdated = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => RestaurantOrdersDetailPage(order: order));

    if (isUpdated != null && isUpdated) {
      // Si existió una actualización refrescar la página
      /*if (isUpdated) {
        refresh();
      }*/
      print('Variable isUpdate: $isUpdated');
      refresh();
    } else {
      isUpdated = false;
      print('Variable isUpdate no actualizó: $isUpdated');
    }
  }
}
