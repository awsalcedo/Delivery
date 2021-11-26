import 'package:delivery_alex_salcedo/src/models/mercado_pago_card_token.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_document_type.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/mercado_pago_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

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
}
