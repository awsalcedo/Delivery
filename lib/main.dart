import 'package:delivery_alex_salcedo/src/pages/client/products/list/client_products_list_page.dart';
import 'package:delivery_alex_salcedo/src/pages/login/login_page.dart';
import 'package:delivery_alex_salcedo/src/pages/register/register_page.dart';
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
          'client/products/list': (BuildContext contex) =>
              ClientProductsListPage()
        },
        theme: ThemeData(
          primaryColor: MyColors.primaryColor,
          //fontFamily: 'NimbusSans'
        ));
  }
}
