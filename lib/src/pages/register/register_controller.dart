import 'dart:convert';
import 'dart:io';

import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/users_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class RegisterController {
  BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();

  PickedFile pickedFile;
  File imageFile;
  Function refresh;

  ProgressDialog _progressDialog;

  bool isEnable = true;

  // ignore: missing_return
  Future init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
  }

  void register() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validacion de campos
    if (email.isEmpty ||
        name.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      MySnackBar.show(context, 'Por favor ingrese todos los campos');
      return;
    }

    if (confirmPassword != password) {
      MySnackBar.show(context, 'Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      MySnackBar.show(
          context, 'La contraseña debe tener al menos 6 caracteres');
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

    User user = new User(
        email: email,
        name: name,
        lastname: lastName,
        phone: phone,
        password: password);

    Stream stream = await usersProvider.createWithImage(user, imageFile);
    stream.listen((res) {
      // Ocultar el cuadro de dialogo de progreso
      _progressDialog.close();

      // Parsear la respuesta
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

      print('RESPUESTA: ${responseApi.toJson()}');

      MySnackBar.show(context, responseApi.message);

      if (responseApi.success) {
        Future.delayed(Duration(seconds: 3), () {
          // Se envía al usuario a la pantalla de login para que inicie sesión
          Navigator.pushReplacementNamed(context, 'login');
        });
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
