import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:tests_flutter/services/env_service.dart';
import 'package:tests_flutter/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Fonction de gestion des messages en arrière-plan
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
    NotificationsService.showNotification(message);
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
            'high_importance_channel', 'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            tag: "unique_tag_test");

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(threadIdentifier: "unique_thread_test");

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      1,
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

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

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
      }
    });

    // Gérer les messages ouverts depuis un état en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print("Notification cliquée alors que l'app était en arrière-plan");
      }
    });
  }

  Future<String> generateAccessToken() async {
    // Chargez le fichier JSON à l'aide de rootBundle
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString('assets/keys/service-account-key.json'),
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client =
        await clientViaServiceAccount(serviceAccountCredentials, scopes);

    return client.credentials.accessToken.data;
  }

  //Send new notif push
  Future<void> sendPushNotification({
    required String title,
    required String body,
  }) async {
    final SecureStorageService secureStorageService = SecureStorageService();
    final pushToken = await secureStorageService.getData("pushToken");
    if (pushToken == null) {
      return;
    }
    final accessToken = await generateAccessToken();
    final url = Uri.parse(EnvService().getSendNotifsUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'message': {
          'notification': {
            'title': title,
            'body': body,
          },
          'token': pushToken,
        },
      }),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification envoyée avec succès.');
      }
    } else {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi : ${response.body}');
      }
    }
  }
}
