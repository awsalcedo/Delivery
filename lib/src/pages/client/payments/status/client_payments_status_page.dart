import 'package:delivery_alex_salcedo/src/pages/client/payments/status/client_payments_status_controller.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class ClientPaymentsStatusPage extends StatefulWidget {
  const ClientPaymentsStatusPage({Key key}) : super(key: key);

  @override
  _ClientPaymentsStatusPageState createState() =>
      _ClientPaymentsStatusPageState();
}

class _ClientPaymentsStatusPageState extends State<ClientPaymentsStatusPage> {
  ClientPaymentsStatusController _con = new ClientPaymentsStatusController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_clipPathOval(), _textCardDetail(), _textCardStatus()],
      ),
      bottomNavigationBar: Container(
        height: 90,
        child: _buttonCheckout(),
      ),
    );
  }

  Widget _textCardDetail() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: _con.mercadoPagoPayment?.status == 'approved'
          ? Text(
              'La orden fue procesada exitosamente usando (${_con.mercadoPagoPayment?.paymentMethodId?.toUpperCase() ?? ''} **** ${_con.mercadoPagoPayment?.card?.lastFourDigits ?? ''})',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            )
          : Text(
              'Su pago fue rechazado',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _textCardStatus() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: _con.mercadoPagoPayment?.status == 'approved'
          ? Text(
              'Puede verificar el estado de su compra en la sección de Mis Pedidos',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            )
          : Text(
              _con.errorMessage ?? '',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _clipPathOval() {
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        height: 250,
        width: double.infinity,
        color: MyColors.primaryColor,
        child: SafeArea(
          child: Column(
            children: [
              _con.mercadoPagoPayment?.status == 'approved'
                  ? Icon(Icons.check_circle,
                      color: MyColors.statusCardCircle, size: 150)
                  : Icon(Icons.cancel,
                      color: MyColors.statusCardCircle, size: 150),
              Text(
                _con.mercadoPagoPayment?.status == 'approved'
                    ? 'Gracias por su compra'
                    : 'Falló la transacción',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonCheckout() {
    return Container(
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _con.finishShopping,
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'FINALIZAR COMPRA',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 2),
                height: 30,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
