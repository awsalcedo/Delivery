import 'package:delivery_alex_salcedo/src/models/address.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_card_token.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_installment.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_issuer.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_payment.dart';
import 'package:delivery_alex_salcedo/src/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery_alex_salcedo/src/models/order.dart';
import 'package:delivery_alex_salcedo/src/models/product.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/mercado_pago_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/my_snackbar.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ClientPaymentsInstallmetsController {
  BuildContext context;
  Function refresh;

  User user;
  SharedPref _sharedPref = new SharedPref();

  MercadoPagoProvider _mercadoPagoProvider = new MercadoPagoProvider();

  MercadoPagoCardToken cardToken;
  List<Product> selectedProducts = [];
  double totalPayment = 0;

  MercadoPagoPaymentMethodInstallments installments;
  List<MercadoPagoInstallment> installmentsList = [];
  MercadoPagoIssuer issuer;
  MercadoPagoPayment creditCardPayment;

  String selectedInstallment;

  Address address;

  ProgressDialog progressDialog;

  String identificationType;
  String identificationNumber;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Obtener los parámetros
    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    // Obtener el token
    cardToken = MercadoPagoCardToken.fromJsonMap(arguments['card_token']);
    identificationType = arguments['identification_type'];
    identificationNumber = arguments['identification_number'];

    progressDialog = ProgressDialog(context: context);

    // Leer la orden almacenada en cache
    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;
    user = User.fromJson(await _sharedPref.read('user'));

    address = Address.fromJson(await _sharedPref.read('address'));

    _mercadoPagoProvider.init(context, user);

    getTotalPayment();
    getInstallments();
  }

  // Calcular el valor total a pagar
  void getTotalPayment() {
    // Recorrer la lista de procusctos seleccionados
    selectedProducts.forEach((product) {
      totalPayment = totalPayment + (product.quantity * product.price);
    });
    refresh();
  }

  // Obtener las cuotas de la API de Mercado Pago
  void getInstallments() async {
    installments = await _mercadoPagoProvider.getInstallments(
        cardToken.firstSixDigits, totalPayment);
    print('OBJECT INSTALLMENTS: ${installments.toJson()}');

    // Cargar la lista de cuotas (payerCosts)
    installmentsList = installments.payerCosts;
    issuer = installments.issuer;

    refresh();
  }

  void createPay() async {
    if (selectedInstallment == null) {
      MySnackBar.show(context, 'Debe seleccionar el número de cuotas');
      return;
    }

    Order order = new Order(
        idAddress: address.id, idClient: user.id, products: selectedProducts);

    progressDialog.show(max: 100, msg: 'Realizando transacción');

    Response response = await _mercadoPagoProvider.createPayment(
        cardId: cardToken.cardId,
        transactionAmount: totalPayment,
        installments: int.parse(selectedInstallment),
        paymentMethodId: installments.paymentMethodId,
        paymentTypeId: installments.paymentTypeId,
        issuerId: installments.issuer.id,
        emailCustomer: user.email,
        cardToken: cardToken.id,
        identificationType: identificationType,
        identificationNumber: identificationNumber,
        order: order);

    progressDialog.close();

    if (response != null) {
      print('SE GENERO UN PAGO antes ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        print('SE GENERO UN PAGO ${response.body}');

        // Obejto que contiene la respuesta en formato json del pago realizado en la API de Mercado Pago
        creditCardPayment = MercadoPagoPayment.fromJsonMap(data);

        Navigator.pushNamedAndRemoveUntil(
            context, 'client/payments/status', (route) => false,
            arguments: creditCardPayment.toJson());

        print('CREDIT CART PAYMENT ${creditCardPayment.toJson()}');
      } else if (response.statusCode == 501) {
        if (data['err']['status'] == 400) {
          badRequestProcess(data);
        } else {
          badTokenProcess(data['status'], installments);
        }
      }
    }
  }

  ///SI SE RECIBE UN STATUS 400
  void badRequestProcess(dynamic data) {
    Map<String, String> paymentErrorCodeMap = {
      '3034': 'Información de la tarjeta inválida',
      '205': 'Ingrese el número de tu tarjeta',
      '208': 'Digite un mes de expiración',
      '209': 'Digite un año de expiración',
      '212': 'Ingrese su documento',
      '213': 'Ingrese su documento',
      '214': 'Ingrese tu documento',
      '220': 'Ingrese su banco emisor',
      '221': 'Ingrese el nombre y apellido',
      '224': 'Ingrese el código de seguridad',
      'E301': 'Existe algo mal en el número. Vuelva a ingresarlo.',
      'E302': 'Revise el código de seguridad',
      '316': 'Ingrese un nombre válido',
      '322': 'Revise su documento',
      '323': 'Revise su documento',
      '324': 'Revise su documento',
      '325': 'Revise la fecha',
      '326': 'Revise la fecha'
    };
    String errorMessage;
    print('CODIGO ERROR ${data['err']['cause'][0]['code']}');

    if (paymentErrorCodeMap.containsKey('${data['err']['cause'][0]['code']}')) {
      print('ENTRO IF');
      errorMessage = paymentErrorCodeMap['${data['err']['cause'][0]['code']}'];
    } else {
      errorMessage = 'No se pudo procesar su pago';
    }
    MySnackBar.show(context, errorMessage);
    // Navigator.pop(context);
  }

  void badTokenProcess(
      String status, MercadoPagoPaymentMethodInstallments installments) {
    Map<String, String> badTokenErrorCodeMap = {
      '106': 'No puedes realizar pagos a usuarios de otros paises.',
      '109':
          '${installments.paymentMethodId} no procesa pagos en $selectedInstallment cuotas',
      '126': 'No pudimos procesar tu pago.',
      '129':
          '${installments.paymentMethodId} no procesa pagos del monto seleccionado.',
      '145': 'No pudimos procesar tu pago',
      '150': 'No puedes realizar pagos',
      '151': 'No puedes realizar pagos',
      '160': 'No pudimos procesar tu pago',
      '204':
          '${installments.paymentMethodId} no está disponible en este momento.',
      '801':
          'Realizaste un pago similar hace instantes. Intenta nuevamente en unos minutos',
    };
    String errorMessage;
    if (badTokenErrorCodeMap.containsKey(status.toString())) {
      errorMessage = badTokenErrorCodeMap[status];
    } else {
      errorMessage = 'No pudimos procesar tu pago';
    }
    MySnackBar.show(context, errorMessage);
  }
}
