import 'package:delivery_alex_salcedo/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientAddressCreatePage extends StatefulWidget {
  ClientAddressCreatePage({Key key}) : super(key: key);

  @override
  _ClientAddressCreatePageState createState() =>
      _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {
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
        title: Text('Nueva dirección'),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
