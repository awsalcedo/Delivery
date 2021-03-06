import 'dart:convert';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/address.dart';
import 'package:delivery_alex_salcedo/src/models/response_api.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddressProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/address';
  BuildContext context;
  User sessionUser;

  // ignore: missing_return
  Future init(BuildContext context, User sessionUser) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<ResponseApi> create(Address address) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(address);

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

  Future<List<Address>> getByUser(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_api/findByUser/$idUser');

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

      // Obtener las direcciones
      final data = json.decode(res.body);

      // Transformar una lista de objetos json a una List<Address>
      Address address = Address.fromJsonList(data);
      return address.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
