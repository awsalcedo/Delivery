import 'package:delivery_alex_salcedo/src/pages/client/orders/map/client_orders_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientOrdersMapPage extends StatefulWidget {
  ClientOrdersMapPage({Key key}) : super(key: key);

  @override
  _ClientOrdersMapPageState createState() => _ClientOrdersMapPageState();
}

class _ClientOrdersMapPageState extends State<ClientOrdersMapPage> {
  ClientOrdersMapController _con = new ClientOrdersMapController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.67,
              child: _googleMaps()),
          SafeArea(
            child: Column(
              children: [
                _buttomCenterPosition(),
                Spacer(),
                _orderDataCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _googleMaps() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
          _con.initialPosition, // Posición inicial dentro del mapa
      onMapCreated: _con.onMapCreated, // Controllador de Google Maps
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  Widget _buttomCenterPosition() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderDataCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.33,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3))
          ]),
      child: Column(
        children: [
          _listTileAddress(
              _con.order?.address?.neighborhood, 'Barrio', Icons.my_location),
          _listTileAddress(
              _con.order?.address?.address, 'Dirección', Icons.location_on),
          Divider(
            color: Colors.grey[400],
            endIndent: 30,
            indent: 30,
          ),
          _clientInfo(),
        ],
      ),
    );
  }

  Widget _listTileAddress(String title, String subtitle, IconData iconData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title ?? '', style: TextStyle(fontSize: 12)),
        subtitle: Text(subtitle),
        trailing: Icon(iconData),
      ),
    );
  }

  Widget _clientInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            child: FadeInImage(
              placeholder: AssetImage('assets/img/no-image.png'),
              image: _con.order?.delivery?.image != null
                  ? NetworkImage(_con.order?.delivery?.image)
                  : AssetImage('assets/img/no-image.png'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              '${_con.order?.delivery?.name ?? ''} ${_con.order?.delivery?.lastname ?? ''}',
              style: TextStyle(color: Colors.black, fontSize: 15),
              maxLines: 1,
            ),
          ),
          Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey[200]),
            child: IconButton(
                icon: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                onPressed: _con.openCallCustomer),
          )
        ],
      ),
    );
  }

  void refresh() {
    // Se refesque la pantalla sino está montado
    if (!mounted) return;
    setState(() {});
  }
}
