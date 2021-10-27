import 'package:delivery_alex_salcedo/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:delivery_alex_salcedo/src/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientAddressListPage extends StatefulWidget {
  ClientAddressListPage({Key key}) : super(key: key);

  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage> {
  ClientAddressListController _con = new ClientAddressListController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        actions: [_iconAdd()],
        title: Text('Direcciones'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            _textSelectedAddress(),
            Container(
                margin: EdgeInsets.only(top: 30),
                child: NoDataWidget(text: 'Agrega una nueva dirección')),
            _buttonNewAddress()
          ],
        ),
      ),
      bottomNavigationBar: _buttonAccept(),
    );
  }

  Widget _iconAdd() {
    return IconButton(
      onPressed: _con.goToNewAddress,
      icon: Icon(Icons.add),
      color: Colors.white,
    );
  }

  Widget _textSelectedAddress() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Elige donde recibir tus pedidos',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          'ACEPTAR',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: MyColors.primaryColor),
      ),
    );
  }

  Widget _buttonNewAddress() {
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: _con.goToNewAddress,
        child: Text('Nueva dirección'),
        style: ElevatedButton.styleFrom(primary: Colors.red),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
