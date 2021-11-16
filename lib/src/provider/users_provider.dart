import 'dart:convert';
import 'dart:io';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider {
  String _url = Environment.API_DELIVERY;
  String _api = "/api/users";
  BuildContext context;
  User sessionUser;

  Future init(BuildContext context, {User sessionUser}) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  // Llamar al servicio de creacion de usuario con imagen
  Future<Stream> createWithImage(User user, File image) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      final request = http.MultipartRequest('POST', url);

      // Si el usuario selecciono una imagen
      if (image != null) {
        request.files.add(http.MultipartFile('image',
            http.ByteStream(image.openRead().cast()), await image.length(),
            filename: basename(image.path)));
      }

      request.fields['user'] = json.encode(user);

      // Se envia la peticion al backend de NodeJS
      final response = await request.send();
      return response.stream.transform(utf8.decoder);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Llamar al servicio de creacion de usuario sin imagen
  Future<ResponseApi> create(User user) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user);

      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi> login(String email, String password) async {
    try {
      Uri url = Uri.http(_url, '$_api/login');
      String bodyParams = json.encode({'email': email, 'password': password});

      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Llamar al servicio de actualizar datos del usuario
  Future<Stream> update(User user, File image) async {
    try {
      Uri url = Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest('PUT', url);

      request.headers['Authorization'] = sessionUser.sessionToken;

      // Si el usuario selecciono una imagen
      if (image != null) {
        request.files.add(http.MultipartFile('image',
            http.ByteStream(image.openRead().cast()), await image.length(),
            filename: basename(image.path)));
      }

      request.fields['user'] = json.encode(user);

      // Se envia la peticion al backend de NodeJS
      final response = await request.send();

      if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: 'La sesión expiró');

        // Cerrar la sesseion del usuario
        new SharedPref().logout(context, sessionUser.id);
      }

      return response.stream.transform(utf8.decoder);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Obtener los datos del usuario por ID
  Future<User> getById(String id) async {
    try {
      Uri url = Uri.http(_url, '$_api/findById/$id');

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };

      final res = await http.get(url, headers: headers);

      // Si no está autorizado
      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'La sesión expiró');

        // Cerrar la sesseion del usuario
        new SharedPref().logout(context, sessionUser.id);
      }

      final data = json.decode(res.body);

      User user = User.fromJson(data);

      return user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Llamar al servicio para cerrar sesión del usuario
  Future<ResponseApi> logout(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_api/logout');
      String bodyParams = json.encode({'id': idUser});

      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // LLama al servicio para obtener los usuarios con el rol de repartidor
  Future<List<User>> getDelivery() async {
    try {
      Uri url = Uri.http(_url, '$_api/findDelivery');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.get(url, headers: headers);

      // Acceso no autorizado
      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'La sesion expiró');
        new SharedPref().logout(context, sessionUser.id);
      }

      final data = json.decode(res.body);
      User user = User.fromJsonList(data);
      return user.toList;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
