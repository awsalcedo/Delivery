import 'package:delivery_alex_salcedo/src/models/address.dart';
import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/address_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/orders_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientAddressListController {
  BuildContext context;
  Function refresh;

  List<Address> address = [];
  AddressProvider _addressProvider = new AddressProvider();
  User user;
  SharedPref _sharedPref = new SharedPref();

  int radioValue = 0;

  bool isCreated;

  Map<String, dynamic> dataIsCreated;

  OrdersProvider _ordersProvider = new OrdersProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));

    // Inicializar providers
    _addressProvider.init(context, user);
    _ordersProvider.init(context, user);

    refresh();
  }

  void createOrder() async {
    //Obtener la dirección seleccionada por el usuario, que está alamcenada en cache
    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});

    //Obtener la lista de productos seleccionada por el usuario, que está alamcenada en cache
    List<Product> selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;
    Order order = new Order(
        idClient: user.id, idAddress: a.id, products: selectedProducts);
    ResponseApi responseApi = await _ordersProvider.create(order);

    print('Respuesta orden: ${responseApi.message}');

    //Navigator.pushNamed(context, 'client/payments/create');
  }

  void handleRadioValueChange(int value) async {
    radioValue = value;
    _sharedPref.save('address', address[value]);

    refresh();
    print('Valor seleccionado: $radioValue');
  }

  Future<List<Address>> getAddress() async {
    address = await _addressProvider.getByUser(user.id);

    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    int index = address.indexWhere((ad) => ad.id == a.id);

    if (index != -1) {
      radioValue = index;
    }
    print('SE GUARDO LA DIRECCION: ${a.toJson()}');

    return address;
  }

  void goToNewAddress() async {
    var result = await Navigator.pushNamed(context, 'client/address/create');

    if (result != null) {
      if (result) {
        refresh();
      }
    }
  }
}
