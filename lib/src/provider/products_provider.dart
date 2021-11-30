import 'dart:convert';
import 'dart:io';

import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ProductsProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/products';
  BuildContext context;
  User sessionUser;

  // ignore: missing_return
  Future init(BuildContext context, User sessionUser) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  // Llamar al servicio de creacion de producto con imagen
  Future<Stream> create(Product product, List<File> images) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = sessionUser.sessionToken;

      // Añadir cada una de las imágenes
      for (int i = 0; i < images.length; i++) {
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(images[i].openRead().cast()),
            await images[i].length(),
            filename: basename(images[i].path)));
      }

      request.fields['product'] = json.encode(product);

      // Se envia la peticion al backend de NodeJS
      final response = await request.send();
      return response.stream.transform(utf8.decoder);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Llamar al servicio para obtener los productos por categoría
  Future<List<Product>> getProductsByCategory(String idCategory) async {
    try {
      Uri url = Uri.http(_url, '$_api/findByCategory/$idCategory');

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

      // Obtener los productos
      final data = json.decode(res.body);

      // Transformar una lista de objetos json a una List<Product>
      Product product = Product.fromJsonList(data);
      return product.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Product>> getByCategoryAndProductName(
      String idCategory, String productName) async {
    try {
      Uri url = Uri.http(
          _url, '$_api/findByCategoryAndProductName/$idCategory/$productName');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesión expirada');
        new SharedPref().logout(context, sessionUser.id);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Product product = Product.fromJsonList(data);
      return product.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
