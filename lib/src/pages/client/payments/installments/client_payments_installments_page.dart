import 'package:delivery_alex_salcedo/src/models/mercado_pago_installment.dart';
import 'package:delivery_alex_salcedo/src/pages/client/payments/installments/client_payments_installments_controller.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientPaymentsInstallmentsPage extends StatefulWidget {
  ClientPaymentsInstallmentsPage({Key key}) : super(key: key);

  @override
  _ClientPaymentsInstallmentsPageState createState() =>
      _ClientPaymentsInstallmentsPageState();
}

class _ClientPaymentsInstallmentsPageState
    extends State<ClientPaymentsInstallmentsPage> {
  ClientPaymentsInstallmetsController _con =
      new ClientPaymentsInstallmetsController();

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
      appBar: AppBar(
        title: Text('Cuotas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_textDescription(), _dropDownInstallments()],
      ),
      bottomNavigationBar: Container(
        height: 140,
        child: Column(
          children: [
            _textTotalPrice(),
            _buttonConfirmPayment(),
          ],
        ),
      ),
    );
  }

  Widget _buttonConfirmPayment() {
    return Container(
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _con.createPay,
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
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'CONFIRMAR PAGO',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 55, top: 7),
                height: 25,
                child: Icon(
                  Icons.attach_money,
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

  Widget _textTotalPrice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total a pagar:',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            '${_con.totalPayment}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _textDescription() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Text(
        'Seleccione el número de cuotas?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dropDownInstallments() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton(
                  underline: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: MyColors.primaryColor,
                    ),
                  ),
                  elevation: 3,
                  isExpanded: true,
                  hint: Text(
                    'Seleccione el número de cuotas',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  items: _dropDownItems(_con.installmentsList),
                  value: _con.selectedInstallment,
                  onChanged: (option) {
                    setState(() {
                      print('Cuota seleccionada $option');
                      _con.selectedInstallment = option;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(
      List<MercadoPagoInstallment> installmentsList) {
    List<DropdownMenuItem<String>> list = [];
    installmentsList.forEach((installment) {
      list.add(DropdownMenuItem(
        child: Container(
          margin: EdgeInsets.only(top: 7),
          child: Text('${installment.installments}'),
        ),
        value: '${installment.installments}',
      ));
    });

    return list;
  }

  void refresh() {
    setState(() {});
  }
}
