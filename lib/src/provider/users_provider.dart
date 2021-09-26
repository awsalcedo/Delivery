import 'dart:convert';
import 'dart:io';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider {
  String _url = Environment.API_DELIVERY;
  String _api = "/api/users";
  BuildContext context;

  Future init(BuildContext context) {
    this.context = context;
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

  // Obtener los datos del usuario por ID
  Future<User> getById(String id) async {
    try {
      Uri url = Uri.http(_url, '$_api/findById/$id');

      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);

      User user = User.fromJson(data);

      return user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
