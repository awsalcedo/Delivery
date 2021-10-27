import 'package:delivery_alex_salcedo/src/pages/client/address/create/client_address_create_controller.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientAddressCreatePage extends StatefulWidget {
  ClientAddressCreatePage({Key key}) : super(key: key);

  @override
  _ClientAddressCreatePageState createState() =>
      _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {
  ClientAddressCreateController _con = new ClientAddressCreateController();

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
        title: Text('Nueva dirección'),
      ),
      bottomNavigationBar: _buttonAccept(),
      body: Column(
        children: [
          _textCompleteData(),
          _textFieldAddress(),
          _textFieldNeighborhood(),
          _textFieldReferencePoint()
        ],
      ),
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: ElevatedButton(
        onPressed: _con.createAddress,
        child: Text('CREAR DIRECCIÓN'),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: MyColors.primaryColor),
      ),
    );
  }

  Widget _textCompleteData() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Complete los siguientes datos',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _textFieldAddress() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.addressController,
        decoration: InputDecoration(
            labelText: 'Dirección',
            suffixIcon: Icon(
              Icons.location_on,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _textFieldNeighborhood() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.neighborhoodController,
        decoration: InputDecoration(
            labelText: 'Barrio',
            suffixIcon: Icon(
              Icons.location_city,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _textFieldReferencePoint() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.refPointController,
        onTap: _con.openMap,
        autofocus: false,
        focusNode: AlwaysDisabledFocusNode(),
        decoration: InputDecoration(
            labelText: 'Punto de referencia',
            suffixIcon: Icon(
              Icons.map,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
