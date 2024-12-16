import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:tests_flutter/services/env_service.dart';
import 'package:tests_flutter/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    await _createNotificationChannels();

    // Initialize Flutter Local Notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) =>
          _handleNotificationTap(payload),
    );

    await _requestPermission();
    await getDevicePushToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundNotification(message);
    });

    // Gérer les messages ouverts depuis un état fermé
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message.data["payload"]);
      }
    });

    // Gérer les messages ouverts depuis un état en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data["payload"]);
    });
  }

  Future _requestPermission() async {
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

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel persistentChannel =
        AndroidNotificationChannel(
            'persistent_channel', 'Persistent Notifications',
            description: 'Channel for persistent notifications',
            importance: Importance.high);

    const AndroidNotificationChannel normalChannel = AndroidNotificationChannel(
        'normal_channel', 'Normal Notifications',
        description: 'Channel for normal notifications',
        importance: Importance.high);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(persistentChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(normalChannel);
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    final notificationType = message.data['type'] ?? 'normal';
    if (kDebugMode) {
      print("type: $notificationType");
    }

    if (notificationType == 'persistent') {
      await _showPersistentNotification(message);
    } else {
      await _showNormalNotification(message);
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (message.notification != null) {
      final instance = NotificationService();
      final notificationType = message.data['type'] ?? 'normal';
      if (kDebugMode) {
        print("type: $notificationType");
      }

      if (notificationType == 'persistent') {
        await instance._showPersistentNotification(message);
      } else {
        await instance._showNormalNotification(message);
      }
    }
  }

  Future<void> _showPersistentNotification(RemoteMessage message) async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'persistent_channel', 'Persistent Notifications',
            tag: 'persistent_tag',
            importance: Importance.high,
            priority: Priority.high),
        iOS: DarwinNotificationDetails(
          threadIdentifier: 'persistent_thread',
        ),
      ),
      payload: message.data['payload'],
    );
  }

  Future<void> _showNormalNotification(RemoteMessage message) async {
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'normal_channel', 'Normal Notifications',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['payload'],
    );
  }

  void _handleNotificationTap(NotificationResponse? payload) {
    debugPrint('Notification tapped with payload: $payload');
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
  Future<void> sendPushNotification(
      {required String title,
      required String body,
      required bool persistent}) async {
    final SecureStorageService secureStorageService = SecureStorageService();
    final pushToken = await secureStorageService.getData("pushToken");
    if (pushToken == null) {
      return;
    }
    final accessToken = await generateAccessToken();
    final url = Uri.parse(EnvService().getSendNotifsUrl);

    if (kDebugMode) {
      print("bearer token: $accessToken");
      print("push token: $pushToken");
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(
        {
          "message": {
            "token": pushToken,
            "data": {"type": persistent ? "persistent" : "normal"},
            "notification": {"title": title, "body": body},
            "android": {
              "notification": {"tag": "persistent_tag"}
            },
            "apns": {
              "payload": {
                "aps": {
                  "content-available": 1,
                  "mutable-content": 1,
                  "thread-id": "persistent_thread"
                }
              }
            }
          },
        },
      ),
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
