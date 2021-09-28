import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:flutter/material.dart';

class RestaurantCategoriesCreateController {
  BuildContext context;
  Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  Future init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
  }

  void createCategory() {
    String name = nameController.text;
    String description = descriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      MySnackBar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    print('Nombre: $name');
    print('Descripción: $description');
  }
}
