import 'dart:async';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/orders_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:url_launcher/url_launcher.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeliveryOrdersMapController {
  BuildContext context;
  Function refresh;
  Position _position;
  String addressName;
  LatLng addressLatLng;
  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-0.2201641, -78.5123274), zoom: 14);

  Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor deliveryMarker;
  BitmapDescriptor placeOfDeliveryMarker;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Order order;
  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  // Para obtener eventos en tiempo real
  StreamSubscription _positionStream;

  OrdersProvider _ordersProvider = new OrdersProvider();
  User user;
  SharedPref _sharedPref = new SharedPref();

  double _distanceBetween;

  IO.Socket socket;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Obtiene la orden enviada desde la página del detalle de las ordenes
    order = Order.fromJson(
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    print('ORDEN: ${order.toJson()}');

    deliveryMarker = await createdMarker('assets/img/delivery2.png');
    placeOfDeliveryMarker = await createdMarker('assets/img/home.png');

    // Conectarse al namespace de socket io
    socket = IO.io(
        'http://${Environment.API_DELIVERY}/orders/delivery', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.connect();

    user = User.fromJson(await _sharedPref.read('user'));

    _ordersProvider.init(context, user);

    checkGPS();
  }

  Future<Null> setLocationDraggableInfo() async {
    if (initialPosition != null) {
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat, lng);
      if (address != null) {
        // Validar que al menos tenga una dirección
        if (address.length > 0) {
          String direction = address[0].thoroughfare;
          String street = address[0].subThoroughfare;
          String city = address[0].locality;
          String department = address[0].administrativeArea;
          addressName = '$direction #$street, $city, $department';
          addressLatLng = new LatLng(lat, lng);

          //print('LAT: ${addressLatLng.latitude}');
          //print('LNG: ${addressLatLng.longitude}');

          refresh();
        }
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }

  // Permite obtener la posición y centrar dentro del mapa
  void updateLocation() async {
    try {
      // Obtener la posición actual y solcictar los permisos
      await _determinePosition();

      // Obtener la última posición conocida del dispositivo, latitud y longitud
      _position = await Geolocator.getLastKnownPosition();

      animateCamaraToPosition(_position.latitude, _position.longitude);

      // Añadir el marcador al mapa
      addMarker('delivery', _position.latitude, _position.longitude,
          'Su posición', '', deliveryMarker);

      addMarker('home', order.address.lat, order.address.lng,
          'Lugar de entrega', '', placeOfDeliveryMarker);

      LatLng from = new LatLng(_position.latitude, _position.longitude);
      // Punto de entrga dell pedido
      LatLng to = new LatLng(order.address.lat, order.address.lng);
      configurePolylines(from, to);

      _positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) {
        // Devuelve la posición actual del repartidor
        _position = position;

        // Emitir la posición del delivery al socket
        emitPositionDelivery();

        // Trazar el marcador del delivery para establecerlo en la posición actual
        addMarker('delivery', _position.latitude, _position.longitude,
            'Su posición', '', deliveryMarker);

        // Ubicar la cámara en el centro donde esta ubicado el repartidor
        animateCamaraToPosition(_position.latitude, _position.longitude);

        isCloseToPlaceOfDelivery();

        refresh();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Verificar si el usuario activó el GPS
  void checkGPS() async {
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (islocationEnabled) {
      updateLocation();
    } else {
      // Requerir al usuario que habilite el GPS
      bool locationGPS = await location.Location().requestService();
      // Si el usuario aceptó ahabilitar el GPS
      if (locationGPS) {
        updateLocation();
      }
    }
  }

  // Permite animar la cámara hasta la posición en la que nos encontramos actualmente
  Future animateCamaraToPosition(double lat, double lng) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 13, bearing: 0)));
    }
  }

  // Método para determinar la posición actual del dispositivo
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Determinar si el GPS del dispositivo está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Solicitar los permisos para empezar a utilizar la ubicación
    permission = await Geolocator.checkPermission();
    // Usuario no permite que se acceda a la localización
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // Si el usuario selecciona que la aplicación nunca accederá a los servicios de ubicación
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Retorna la posición actual del dispositivo
    return await Geolocator.getCurrentPosition();
  }

  // Obtener la respuesta del punto seleccionado para pasarla al campo punto de referencia
  void selectRefPoint() {
    Map<String, dynamic> data = {
      'address': addressName,
      'lat': addressLatLng.latitude,
      'lng': addressLatLng.longitude,
    };
    // Cierra la pantalla del mapa y le pasa la información a la pantalla anterior
    Navigator.pop(context, data);
  }

  // Crear un marcador para el mapa a partir de los assets
  Future<BitmapDescriptor> createdMarker(String pathImage) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, pathImage);
    return descriptor;
  }

  // Establecer el marcador dentro del mapa
  void addMarker(String markerId, double lat, double lng, String titleMarker,
      String contentMarker, BitmapDescriptor iconMarkert) {
    // Para diferenciar el marcador que vamos a utilizar
    MarkerId id = MarkerId(markerId);
    // Para saber en que posición vamos a colocar el ícono en el mapa
    Marker marker = Marker(
        markerId: id,
        icon: iconMarkert,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: titleMarker, snippet: contentMarker));

    markers[id] = marker;
    refresh();
  }

  //Establecer las polylines paa la ruta
  Future<void> configurePolylines(LatLng from, LatLng to) async {
    // Establecer tanto el punto inicial como el punto destino
    PointLatLng pointFrom = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointTo = PointLatLng(to.latitude, to.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS, pointFrom, pointTo);

    // Recorrer los puntos
    for (PointLatLng point in result.points) {
      // Agregar el punto
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: MyColors.primaryColor,
        points: points,
        width: 6);

    polylines.add(polyline);

    refresh();
  }

  void openCallCustomer() {
    launch("tel://${order.client.phone}");
  }

  void dispose() {
    //Dejar de escuchar los eventos cuando el usuario salga de la página o cierre la aplicación
    _positionStream?.cancel();
    // Desconectarse del socket
    socket?.disconnect();
  }

  // Actualizar el estado de la orden a ENTREGADO
  void updateToDeliveredStatus() async {
    // Si la distancia entre el punto de entrega y el repartidor es menor menor igual a 200 metros
    // realizamos la actualización del estado de la orden a ENTREGADO
    if (_distanceBetween <= 200) {
      ResponseApi responseApi =
          await _ordersProvider.updateToDeliveredStatus(order);
      if (responseApi.success) {
        Fluttertoast.showToast(
            msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
        // Enviar a la pantalla principal
        Navigator.pushNamedAndRemoveUntil(
            context, 'delivery/orders/list', (route) => false);
      }
    } else {
      // Mostrar un mensaje para indicarle al repartidor que debe estar más cerca a la posición de entrega
      MySnackBar.show(context, 'Debe estar más cerca al lugar de entrega');
    }
  }

  void isCloseToPlaceOfDelivery() {
    // Obtener la distancia que existe entre el punto donde se encuentra el repartidor y el lugar de entrega de la orden
    _distanceBetween = Geolocator.distanceBetween(_position.latitude,
        _position.longitude, order.address.lat, order.address.lng);
    print('------ DISTANCIA: $_distanceBetween');
  }

  void launchWaze() async {
    var url =
        'waze://?ll=${order.address.lat.toString()},${order.address.lng.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${order.address.lat.toString()},${order.address.lng.toString()}&navigate=yes';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void launchGoogleMaps() async {
    var url =
        'google.navigation:q=${order.address.lat.toString()},${order.address.lng.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${order.address.lat.toString()},${order.address.lng.toString()}';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  // Emitir la posición actual del repartidor
  void emitPositionDelivery() {
    socket.emit('position_delivery', {
      'id_order': order.id,
      'lat': _position.latitude,
      'lng': _position.longitude
    });
  }
}
