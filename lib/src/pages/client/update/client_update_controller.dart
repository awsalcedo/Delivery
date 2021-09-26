import 'dart:convert';
import 'dart:io';

import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/users_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientUpdateController {
  BuildContext context;
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();

  PickedFile pickedFile;
  File imageFile;
  Function refresh;

  ProgressDialog _progressDialog;

  bool isEnable = true;

  User user;
  SharedPref _sharedPref = new SharedPref();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));
    nameController.text = user.name;
    lastNameController.text = user.lastname;
    phoneController.text = user.phone;
    refresh();
  }

  void update() async {
    String name = nameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phone = phoneController.text.trim();

    // Validacion de campos
    if (name.isEmpty || lastName.isEmpty || phone.isEmpty) {
      MySnackBar.show(context, 'Por favor ingrese todos los campos');
      return;
    }

    if (imageFile == null) {
      MySnackBar.show(context, 'Seleccione una imagen');
      return;
    }

    // Mostrar el cuadro de dialogo de progreso
    _progressDialog.show(max: 100, msg: 'Por favor espere un momento...');

    // Deshabilitar el boton de registro mientras se termina de realizar el proceso de registro
    // del usuario en la BDD y alamacenar la imagen en Firebase
    isEnable = false;

    User myUser = new User(
      id: user.id,
      name: name,
      lastname: lastName,
      phone: phone,
    );

    Stream stream = await usersProvider.update(myUser, imageFile);
    stream.listen((res) async {
      // Ocultar el cuadro de dialogo de progreso
      _progressDialog.close();

      // Parsear la respuesta
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

      Fluttertoast.showToast(msg: responseApi.message);

      if (responseApi.success) {
        // Obtener el usuario de la BDD por ID
        user = await usersProvider.getById(myUser.id);

        // Guardar los datos obtenidos de la BDD en sesion
        _sharedPref.save('user', user.toJson());

        // Enviar al usuari a la pantalla principal
        Navigator.pushNamedAndRemoveUntil(
            context, 'client/products/list', (route) => false);
      } else {
        isEnable = true;
      }
    });
  }

  // Abrir la galeria o la camara
  Future selectImage(ImageSource imageSource) async {
    pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      // Se crea el archivo que se enviara al backend de NodeJS
      imageFile = File(pickedFile.path);
    }
    // Cierra la pantalla del AlertDialog
    Navigator.pop(context);
    // Refresca la pantalla para que se redibuje la misma
    refresh();
  }

  // Cuadro de dialogo para que el usuario indique el tipo de accion:
  // seleccionar la imagen de galeria o tomar la fotografia
  void showAlertDialog() {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery);
        },
        child: Text('GALERIA'));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera);
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

  void back() {
    Navigator.pop(context);
  }
}
