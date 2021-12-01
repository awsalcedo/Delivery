import 'dart:async';
import 'dart:convert';

import 'package:delivery_alex_salcedo/src/provider/users_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class PushNotificationsProvider {
  AndroidNotificationChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initPushNotifications() async {
    // Cree un canal de notificación de Android
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Cree un canal de notificación de Android
    // Usamos este canal en el archivo `AndroidManifest.xml` para anular el
    // canal FCM predeterminado para habilitar las notificaciones de heads-up.

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Actualice las opciones de presentación de notificaciones en primer plano de iOS para permitir
    // encabeza las notificaciones.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Escuchar las notificaciones que vamos a recibir
  void onMessageListener() async {
    // Recibir notificaciones en segundo plano
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        print('NUEVA NOTIFICACION EN SEGUNDO PLANO: $message');
      }
    });

    // Recibir las notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('NUEVA NOTIFICACION EN PRIMER PLANO');

      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });

    // Se ejecuta cuando realizamos click sobre la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  void saveToken(String idUser) async {
    // Obtener el token de notificaciones
    String token = await FirebaseMessaging.instance.getToken();
    UsersProvider usersProvider = new UsersProvider();
    // Guardar el token de notificaciones en la base de datos
    await usersProvider.updateNotificationToken(idUser, token);
  }

  Future<void> sendMessage(
      String to, Map<String, dynamic> data, String title, String body) async {
    Uri url = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAyOqz1h8:APA91bFo_PQ6qLErgY8C7e-S9vwf91UNK2Pwj94Xwl4rkL40xtSr2t8E5880e2BJB6DlgMTLEQkZTag9m8RPh281eumkGCOQIZoEc7Sm8TLhH1cpLkBURg1o5MDCLX48PWdi08nXJMkv'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to
        }));
  }

  Future<void> sendMessageMultiple(List<String> toList,
      Map<String, dynamic> data, String title, String body) async {
    Uri url = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAyOqz1h8:APA91bFo_PQ6qLErgY8C7e-S9vwf91UNK2Pwj94Xwl4rkL40xtSr2t8E5880e2BJB6DlgMTLEQkZTag9m8RPh281eumkGCOQIZoEc7Sm8TLhH1cpLkBURg1o5MDCLX48PWdi08nXJMkv'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'registration_ids': toList
        }));
  }
}
