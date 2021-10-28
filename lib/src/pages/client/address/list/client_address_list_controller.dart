import 'package:delivery_alex_salcedo/src/models/address.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/address_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/orders_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientAddressListController {
  BuildContext context;
  Function refresh;
  AddressProvider _addressProvider = new AddressProvider();
  User user;
  SharedPref _sharedPref = new SharedPref();
  List<Address> address = [];
  int radioValue = 0;
  bool isCreated;
  Map<String, dynamic> dataIsCreated;
  OrdersProvider _ordersProvider = new OrdersProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    // Obtener el usuario de sesión
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, user);
    _ordersProvider.init(context, user);
    refresh();
  }

  void goToNewAddress() async {
    var result = await Navigator.pushNamed(context, 'client/address/create');

    if (result != null) {
      // Si se creó una nueva dirección
      if (result) {
        refresh();
      }
    }
  }

  Future<List<Address>> getAddress() async {
    // Obtener las direcciones
    address = await _addressProvider.getByUser(user.id);

    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    int index = address.indexWhere((ad) => ad.id == a.id);

    if (index != -1) {
      radioValue = index;
    }
    print('SE GUARDO LA DIRECCION: ${a.toJson()}');

    return address;
  }

  void handleRadioValueChange(int value) async {
    radioValue = value;
    // Almacenar la dirección seleccionada en SharedPreferences
    _sharedPref.save('address', address[value]);

    refresh();
    print('Valor seleccioonado: $radioValue');
  }

  void createOrder() async {
    // Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    // List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    // Order order = new Order(
    //   idClient: user.id,
    //   idAddress: a.id,
    //   products: selectedProducts
    // );
    // ResponseApi responseApi = await _ordersProvider.create(order);
    Navigator.pushNamed(context, 'client/payments/create');
  }
}
