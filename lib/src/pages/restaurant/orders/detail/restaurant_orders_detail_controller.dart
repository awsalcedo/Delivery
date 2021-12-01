import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/orders_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/push_notifications_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/users_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantOrdersDetailController {
  BuildContext context;
  Function refresh;

  Product product;

  int counter = 1;
  double productPrice;

  SharedPref _sharedPref = new SharedPref();

  double total = 0;
  Order order;

  User user;
  List<User> usersDelivery = [];
  UsersProvider _usersProvider = new UsersProvider();
  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  String idDelivery;

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;

    // Obtener el usuario de sesion almacenado en la cache
    user = User.fromJson(await _sharedPref.read('user'));

    // Inicializar providers
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);

    getTotal();
    getUsersDelivery();
    refresh();
  }

  // Enviar una notificación
  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(
        tokenDelivery, data, 'PEDIDO ASIGNADO', 'le han asignado un pedido');
  }

  void updateOrder() async {
    if (idDelivery != null) {
      order.idDelivery = idDelivery;
      ResponseApi responseApi =
          await _ordersProvider.updateToDispatchedStatus(order);
      // Obtener el delivery por su id
      User deliveryUser = await _usersProvider.getById(order.idDelivery);
      print(
          'TOKEN DE NOTIFICACIONES DEL DELIVERY: ${deliveryUser.notificationToken}');
      sendNotification(deliveryUser.notificationToken);

      Fluttertoast.showToast(
          msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      // Regresar a la pantalla de la lista de ordenes indicando que hubo una actualización
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: 'Seleccione el repartidor');
    }
  }

  void getUsersDelivery() async {
    usersDelivery = await _usersProvider.getDelivery();
    refresh();
  }

  void getTotal() {
    total = 0;
    order.products.forEach((product) {
      total = total + (product.price * product.quantity);
    });
    refresh();
  }
}
