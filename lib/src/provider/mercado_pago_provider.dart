import 'package:delivery_alex_salcedo/src/api/environment.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_document_type.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class MercadoPagoProvider {
  String _urlMercadoPago = 'api.mercadopago.com';
  String _url = Environment.API_DELIVERY;

  // Obtener las credenciales generadas previamente en la plataforma deMercado Pago
  final _mercadoPagoCredentials = Environment.mercadoPagoCredentials;

  BuildContext context;
  User user;

  // ignore: missing_return
  Future init(BuildContext context, User user) {
    this.context = context;
    this.user = user;
  }

  // Permite obetener los tipos de identiificaciones válidos en Mercado Pago
  Future<List<MercadoPagoDocumentType>> getIdentificationTypes() async {
    try {
      final url = Uri.https(_urlMercadoPago, '/v1/identification_types',
          {'access_token': _mercadoPagoCredentials.accessToken});

      print('URL_GET TIPO IDENTIFICACIONES: $url');
      final res = await http.get(url);
      final data = json.decode(res.body);
      final result = new MercadoPagoDocumentType.fromJsonList(data);

      return result.documentTypeList;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Crear el pago en la plataforma de Mercado Pago
  Future<Response> createPayment({
    @required String cardId,
    @required double transactionAmount,
    @required int installments,
    @required String paymentMethodId,
    @required String paymentTypeId,
    @required String issuerId,
    @required String emailCustomer,
    @required String cardToken,
    @required String identificationType,
    @required String identificationNumber,
    @required Order order,
  }) async {
    try {
      final url = Uri.http(_url, '/api/payments/createPay',
          {'publick_key': _mercadoPagoCredentials.publicKey});

      // Crear un mapa con los datos a enviar a la API de Mercado Pago
      Map<String, dynamic> body = {
        'order': order,
        'card_id': cardId,
        'description': 'Delivery Alex Salcedo',
        'transaction_amount': transactionAmount,
        'installments': installments,
        'payment_method_id': paymentMethodId,
        'payment_type_id': paymentTypeId,
        'token': cardToken,
        'issuer_id': issuerId,
        'payer': {
          'email': emailCustomer,
          'identification': {
            'type': identificationType,
            'number': identificationNumber,
          }
        }
      };

      print('PARAMS: $body');

      String bodyParams = json.encode(body);

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': user.sessionToken
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesión expirada');
        new SharedPref().logout(context, user.id);
        return null;
      }

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Obtener el número de cuotas de la API de Mercado Pago
  Future<MercadoPagoPaymentMethodInstallments> getInstallments(
      String bin, double amount) async {
    try {
      print('BIN: $bin');
      print('ACCES_TOKEN: $_mercadoPagoCredentials.accessToken');
      final url =
          Uri.https(_urlMercadoPago, '/v1/payment_methods/installments', {
        'access_token': _mercadoPagoCredentials.accessToken,
        'bin': bin,
        'amount': '$amount'
      });

      print('URL_GETINSTALLMENTS: $url');
      final res = await http.get(url);
      final data = json.decode(res.body);
      print('DATA INSTALLMENTS: $data');

      final result =
          new MercadoPagoPaymentMethodInstallments.fromJsonList(data);

      return result.installmentList.first;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Para crear el token que permite asegurar los datos de la tarjeta
  Future<http.Response> createCardToken({
    String cvv,
    String expirationYear,
    int expirationMonth,
    String cardNumber,
    String documentNumber,
    String documentId,
    String cardHolderName,
  }) async {
    try {
      final url = Uri.https(_urlMercadoPago, '/v1/card_tokens',
          {'public_key': _mercadoPagoCredentials.publicKey});

      final body = {
        'security_code': cvv,
        'expiration_year': expirationYear,
        'expiration_month': expirationMonth,
        'card_number': cardNumber,
        'cardholder': {
          'identification': {
            'number': documentNumber,
            'type': documentId,
          },
          'name': cardHolderName
        },
      };

      final res = await http.post(url, body: json.encode(body));

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
