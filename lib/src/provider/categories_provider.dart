import 'dart:convert';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/category.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CategoriesProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/categories';
  BuildContext context;
  User sessionUser;

  Future init(BuildContext context, User sessionUser) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<ResponseApi> create(Category category) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(category);

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken //Asegurar la consulta
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'La sesión expiró');
        new SharedPref().logout(context, sessionUser.id);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Category>> getAll() async {
    try {
      Uri url = Uri.http(_url, '$_api/getAll');

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken //Asegurar la consulta
      };

      final res = await http.get(url, headers: headers);

      // Respuesta no autorizado
      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'La sesión expiró');
        new SharedPref().logout(context, sessionUser.id);
      }

      // Obtener las categorías
      final data = json.decode(res.body);

      // Transformar una lista de objetos json a una List<Category>
      Category category = Category.fromJsonList(data);
      return category.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
