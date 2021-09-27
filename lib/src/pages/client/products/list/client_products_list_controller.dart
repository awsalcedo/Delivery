import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientProductsListController {
  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    //Se carga la sesión del usuario almacenada en la SharedPreferences
    user = User.fromJson(await _sharedPref.read('user'));
    //Actualizar la página
    refresh();
  }

  void logout() {
    _sharedPref.logout(context, user.id);
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }

  void goToUpdatePage() {
    Navigator.pushNamed(context, 'client/update');
  }
}
