import 'dart:io';
import 'dart:convert';
import 'package:delivery_alex_salcedo/src/models/category.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/categories_provider.dart';
import 'package:delivery_alex_salcedo/src/provider/products_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class RestaurantProductsCreateController {
  BuildContext context;
  Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  MoneyMaskedTextController priceController = new MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  ProductsProvider _productsProvider = new ProductsProvider();
  User user;
  SharedPref sharedPref = new SharedPref();
  List<Category> categories = [];
  // Almacenar el id de la categoria seleccionada
  String idCategory;
  // Para lasimagenes
  PickedFile pickedFile;
  File imageFile1;
  File imageFile2;
  File imageFile3;
  ProgressDialog _progressDialog;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _progressDialog = new ProgressDialog(context: context);

    // Obtener el usuario almacenado en las preferencias de usuario
    user = User.fromJson(await sharedPref.read('user'));

    _categoriesProvider.init(context, user);
    _productsProvider.init(context, user);
    getCategories();
  }

  void createProduct() async {
    String name = nameController.text;
    String description = descriptionController.text;
    double price = priceController.numberValue;

    // Validación de ls datos
    if (name.isEmpty || description.isEmpty || price == 0) {
      MySnackBar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    if (imageFile1 == null || imageFile2 == null || imageFile3 == null) {
      MySnackBar.show(context, 'Seleccione la tres imágenes');
      return;
    }

    // Si el usuario no seleccionó una categoria
    if (idCategory == null) {
      MySnackBar.show(context, 'Seleccione una categoría');
      return;
    }

    Product product = new Product(
        name: name,
        description: description,
        price: price,
        idCategory: int.parse(idCategory));

    List<File> images = [];
    images.add(imageFile1);
    images.add(imageFile2);
    images.add(imageFile3);

    _progressDialog.show(max: 100, msg: 'Espere un momento');

    Stream stream = await _productsProvider.create(product, images);
    // Capturar la respuesta de tipo json que nos envía el servidor
    stream.listen((res) {
      _progressDialog.close();
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      MySnackBar.show(context, responseApi.message);

      if (responseApi.success) {
        resetValues();
      }
    });

    print('Producto a guardar: ${product.toJson()}');
  }

  // Método para limpiar los campos de la pantalla
  void resetValues() {
    nameController.text = '';
    descriptionController.text = '';
    priceController.text = '0.0';
    imageFile1 = null;
    imageFile2 = null;
    imageFile3 = null;
    idCategory = null;
    refresh();
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh();
  }

  // Abrir la galeria o la camara
  Future selectImage(ImageSource imageSource, int numberFile) async {
    pickedFile = await ImagePicker().getImage(source: imageSource);
    // Si el usuario seleccionó una imagen
    if (pickedFile != null) {
      if (numberFile == 1) {
        // Se crea el archivo que se enviara al backend de NodeJS
        imageFile1 = File(pickedFile.path);
      } else if (numberFile == 2) {
        // Se crea el archivo que se enviara al backend de NodeJS
        imageFile2 = File(pickedFile.path);
      } else if (numberFile == 3) {
        // Se crea el archivo que se enviara al backend de NodeJS
        imageFile3 = File(pickedFile.path);
      }
    }
    // Cierra la pantalla del AlertDialog
    Navigator.pop(context);
    // Refresca la pantalla para que se redibuje la misma
    refresh();
  }

  // Cuadro de dialogo para que el usuario indique el tipo de accion:
  // seleccionar la imagen de galeria o tomar la fotografia
  void showAlertDialog(int numberFile) {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery, numberFile);
        },
        child: Text('GALERIA'));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera, numberFile);
        },
        child: Text('CAMARA'));

    AlertDialog alertDialog = AlertDialog(
      title: Text('Seleccione su imagen'),
      actions: [galleryButton, cameraButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }
}
