import 'package:delivery_alex_salcedo/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:delivery_alex_salcedo/src/pages/client/products/list/client_products_list_page.dart';
import 'package:delivery_alex_salcedo/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:delivery_alex_salcedo/src/pages/login/login_page.dart';
import 'package:delivery_alex_salcedo/src/pages/register/register_page.dart';
import 'package:delivery_alex_salcedo/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Delivery App Flutter',
        debugShowCheckedModeBanner: false,
        initialRoute: 'login',
        routes: {
          'login': (BuildContext context) => LoginPage(),
          'register': (BuildContext context) => RegisterPage(),
          'client/products/list': (BuildContext context) =>
              ClientProductsListPage(),
          'restaurant/orders/list': (BuildContext context) =>
              RestaurantOrdersListPage(),
          'delivery/orders/list': (BuildContext context) =>
              DeliveryOrderslistPage()
        },
        theme: ThemeData(
          primaryColor: MyColors.primaryColor,
          //fontFamily: 'NimbusSans'
        ));
  }
}
