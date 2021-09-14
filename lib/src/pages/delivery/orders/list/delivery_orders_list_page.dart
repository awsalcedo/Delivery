import 'package:flutter/material.dart';

class DeliveryOrderslistPage extends StatefulWidget {
  DeliveryOrderslistPage({Key key}) : super(key: key);

  @override
  _DeliveryOrderslistPageState createState() => _DeliveryOrderslistPageState();
}

class _DeliveryOrderslistPageState extends State<DeliveryOrderslistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Delivery orders list'),
      ),
    );
  }
}
