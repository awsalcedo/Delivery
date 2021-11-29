import 'package:delivery_alex_salcedo/src/models/mercado_pago_payment.dart';
import 'package:delivery_alex_salcedo/src/models/user.dart';
import 'package:delivery_alex_salcedo/src/provider/users_provider.dart';
import 'package:delivery_alex_salcedo/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientPaymentsStatusController {
  BuildContext context;
  Function refresh;

  MercadoPagoPayment mercadoPagoPayment;

  String errorMessage;

  //PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();

  User user;
  SharedPref _sharedPref = new SharedPref();
  UsersProvider usersProvider = new UsersProvider();
  List<String> tokens = [];

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    // Obtenemos la data de la pantalla de pago de la orden
    mercadoPagoPayment = MercadoPagoPayment.fromJsonMap(arguments);
    print('Mercado pago Payment: ${mercadoPagoPayment.toJson()}');

    // Si el pago fue rechazo mostrar mensajes al usuario
    if (mercadoPagoPayment.status == 'rejected') {
      createErrorMessage();
    }

    user = User.fromJson(await _sharedPref.read('user'));
    usersProvider.init(context, sessionUser: user);

    //tokens = await usersProvider.getAdminsNotificationTokens();
    //sendNotification();
    refresh();
  }

  void sendNotification() {
    List<String> registration_id = [];
    tokens.forEach((t) {
      if (t != null) {
        registration_id.add(t);
      }
    });

    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    /*pushNotificationsProvider.sendMessageMultiple(
        registration_id,
        data,
        'COMPRA EXITOSA',
        'Un cliente ha realizado un pedido'
    );*/
  }

  void finishShopping() {
    Navigator.pushNamedAndRemoveUntil(
        context, 'client/products/list', (route) => false);
  }

  void createErrorMessage() {
    if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_bad_filled_card_number') {
      errorMessage = 'Revisa el número de tarjeta';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_bad_filled_date') {
      errorMessage = 'Revisa la fecha de vencimiento';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_bad_filled_other') {
      errorMessage = 'Revisa los datos de la tarjeta';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_bad_filled_security_code') {
      errorMessage = 'Revisa el código de seguridad de la tarjeta';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_blacklist') {
      errorMessage = 'No pudo ser procesado su pago';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_call_for_authorize') {
      errorMessage =
          'Debe autorizar ante ${mercadoPagoPayment.paymentMethodId} el pago de este monto.';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_card_disabled') {
      errorMessage =
          'Llama a ${mercadoPagoPayment.paymentMethodId} para activar tu tarjeta o usa otro medio de pago';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_card_error') {
      errorMessage = 'No pudimos procesar tu pago';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_card_error') {
      errorMessage = 'No pudimos procesar tu pago';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_duplicated_payment') {
      errorMessage = 'Ya realizó un pago por ese valor';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_high_risk') {
      errorMessage =
          'Eliga otro de los medios de pago, te recomendamos con medios en efectivo';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_insufficient_amount') {
      errorMessage =
          'Tu ${mercadoPagoPayment.paymentMethodId} no tiene fondos suficientes';
    } else if (mercadoPagoPayment.statusDetail ==
        'cc_rejected_invalid_installments') {
      errorMessage =
          '${mercadoPagoPayment.paymentMethodId} no procesa pagos en ${mercadoPagoPayment.installments} cuotas.';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_max_attempts') {
      errorMessage = 'Superó el límite de intentos permitidos';
    } else if (mercadoPagoPayment.statusDetail == 'cc_rejected_other_reason') {
      errorMessage = 'Eliga otra tarjeta u otro medio de pago';
    }
  }
}
