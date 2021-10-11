import 'package:delivery_alex_salcedo/src/models/category.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/categories_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class RestaurantCategoriesCreateController {
  BuildContext context;
  Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  User user;
  SharedPref sharedPref = new SharedPref();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Obtener el usuario almacenado en las preferencias de usuario
    user = User.fromJson(await sharedPref.read('user'));

    _categoriesProvider.init(context, user);
  }

  void createCategory() async {
    String name = nameController.text;
    String description = descriptionController.text;

    // Validación de ls datos
    if (name.isEmpty || description.isEmpty) {
      MySnackBar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    Category category = new Category(name: name, description: description);

    ResponseApi responseApi = await _categoriesProvider.create(category);

    MySnackBar.show(context, responseApi.message);

    if (responseApi.success) {
      // Limpiar el formulario
      nameController.text = '';
      descriptionController.text = '';
    }

    print('Nombre: $name');
    print('Descripción: $description');
  }
}
