import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tests_flutter/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int _messageCount = 0;

  // Fonction de gestion des messages en arrière-plan
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }

  static Future requestPermission() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: false,
          sound: true);
    } else if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }
  }

  static Future getDevicePushToken() async {
    try {
      String? pushToken = await FirebaseMessaging.instance.getToken();
      if (pushToken != null) {
        if (kDebugMode) {
          print(pushToken);
        }
        SecureStorageService().saveData("pushToken", pushToken);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur push token: $e");
      }
      return null;
    }
  }

  static Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          if (kDebugMode) {
            print("Tapped on notification: $data");
          }
          // Redirection logique ici si nécessaire
        }
      },
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> setupNotifications(BuildContext context) async {
    await init(context);

    // Demande des permissions pour iOS/Android
    await requestPermission();
    await getDevicePushToken();

    // Gérer les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Message reçu en premier plan : ${message.notification?.title}");
      }
      NotificationsService.showNotification(message);
    });

    // Gérer les messages ouverts depuis un état fermé
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          print("Notification cliquée alors que l'app était fermée");
        }
        NotificationsService.showNotification(message);
      }
    });

    // Gérer les messages ouverts depuis un état en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print("Notification cliquée alors que l'app était en arrière-plan");
      }
      NotificationsService.showNotification(message);
    });
  }

  //Create new notif push
  String _constructFCMPayload(String? token, String type) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  //Send new notif push
  Future<void> sendPushMessage(String type) async {
    final token = await SecureStorageService().getData("pushToken");
    if (token == null) {
      if (kDebugMode) {
        print('Unable to send FCM message, no token exists.');
      }
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: _constructFCMPayload(token, type),
      );
      if (kDebugMode) {
        print('FCM request for device sent!');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
