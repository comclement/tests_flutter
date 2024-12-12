import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tests_flutter/commons/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tests_flutter/firebase_options.dart';
import 'package:tests_flutter/router/app_router.dart';
import 'package:tests_flutter/services/notifications_service.dart';
import 'package:tests_flutter/services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService.instance.init();

  FirebaseMessaging.onBackgroundMessage(
      NotificationsService.firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tests Flutter',
      theme: themeApp,
      routerConfig: AppRouter.appRouter,
    );
  }
}
