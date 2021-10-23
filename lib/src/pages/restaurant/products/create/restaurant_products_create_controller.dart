import 'package:delivery_alex_salcedo/src/models/category.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/categories_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class RestaurantProductsCreateController {
  BuildContext context;
  Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  MoneyMaskedTextController priceController = new MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  User user;
  SharedPref sharedPref = new SharedPref();
  List<Category> categories = [];
  // Almacenar el id de la categoria seleccionada
  String idCategory;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Obtener el usuario almacenado en las preferencias de usuario
    user = User.fromJson(await sharedPref.read('user'));

    _categoriesProvider.init(context, user);
    getCategories();
  }

  void createProduct() async {
    String name = nameController.text;
    String description = descriptionController.text;

    // Validación de ls datos
    if (name.isEmpty || description.isEmpty) {
      MySnackBar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    print('Nombre: $name');
    print('Descripción: $description');
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh();
  }
}
