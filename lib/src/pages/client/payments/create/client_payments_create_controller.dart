import 'package:delivery_alex_salcedo/src/models/mercado_pago_card_token.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_document_type.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/mercado_pago_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'dart:convert';
import 'package:http/http.dart';

class ClientPaymentsCreateController {
  BuildContext context;
  Function refresh;
  GlobalKey<FormState> keyForm = new GlobalKey();

  String cardNumber = '';
  String expireDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  User user;
  SharedPref _sharedPref = new SharedPref();
  List<MercadoPagoDocumentType> documentTypeList = [];
  MercadoPagoProvider _mercadoPagoProvider = new MercadoPagoProvider();

  String typeDocument = 'CC';

  String expirationYear;
  int expirationMonth;

  MercadoPagoCardToken cardToken;
  TextEditingController documentNumberController = new TextEditingController();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _mercadoPagoProvider.init(context, user);
    getIdentificationTypes();
  }

  // Permite capturar todos los datos que el usuario escribe en los campos de la pantalla
  void onCreditCardModelChanged(CreditCardModel creditCardModel) {
    cardNumber = creditCardModel.cardNumber;
    expireDate = creditCardModel.expiryDate;
    cardHolderName = creditCardModel.cardHolderName;
    cvvCode = creditCardModel.cvvCode;
    isCvvFocused = creditCardModel.isCvvFocused;
    refresh();
  }

  // Obtener los tipos de identificación disponibles
  void getIdentificationTypes() async {
    documentTypeList = await _mercadoPagoProvider.getIdentificationTypes();

    documentTypeList.forEach((document) {
      print('Documento: ${document.toJson()}');
    });
    refresh();
  }

  void createCardToken() async {
    String documentNumber = documentNumberController.text;

    if (cardNumber.isEmpty) {
      MySnackBar.show(context, 'Ingrese el número de la tarjeta');
      return;
    }

    if (expireDate.isEmpty) {
      MySnackBar.show(context, 'Ingrese la fecha de expiración de la tarjeta');
      return;
    }

    if (cvvCode.isEmpty) {
      MySnackBar.show(context, 'Ingrese el código de seguridad de la tarjeta');
      return;
    }

    if (cardHolderName.isEmpty) {
      MySnackBar.show(context, 'Ingrese el titular de la tarjeta');
      return;
    }

    if (documentNumber.isEmpty) {
      MySnackBar.show(context, 'Ingrese el número del documento');
      return;
    }

    if (expireDate != null) {
      List<String> list = expireDate.split('/');
      if (list.length == 2) {
        expirationMonth = int.parse(list[0]);
        expirationYear = '20${list[1]}';
      } else {
        MySnackBar.show(
            context, 'Inserte el mes y el año de expiración de la tarjeta');
      }
    }

    if (cardNumber != null) {
      cardNumber = cardNumber.replaceAll(RegExp(' '), '');
    }

    print('CVV: $cvvCode');
    print('Card Number: $cardNumber');
    print('cardHolderName: $cardHolderName');
    print('documentId: $typeDocument');
    print('documentNumber: $documentNumber');
    print('expirationYear: $expirationYear');
    print('expirationMonth: $expirationMonth');

    Response response = await _mercadoPagoProvider.createCardToken(
        cvv: cvvCode.trim(),
        cardNumber: cardNumber.trim(),
        cardHolderName: cardHolderName,
        documentId: typeDocument,
        documentNumber: documentNumber.trim(),
        expirationYear: expirationYear,
        expirationMonth: expirationMonth);

    if (response != null) {
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        cardToken = new MercadoPagoCardToken.fromJsonMap(data);
        print('CARD TOKEN: ${cardToken.toJson()}');
        Navigator.pushNamed(context, 'client/payments/installments',
            arguments: {
              'identification_type': typeDocument,
              'identification_number': documentNumber,
              'card_token': cardToken.toJson(),
            });
      } else {
        print('HUBO UN ERROR GENERANDO EL TOKEN DE LA TARJETA');
        // Alamcenamos el estatus que devuelve la API de mercado pago
        int status = int.tryParse(data['cause'][0]['code'] ?? data['status']);
        String message = data['message'] ?? 'Error al registrar la tarjeta';
        MySnackBar.show(context, 'Status code $status - $message');
      }
    }
  }
}
