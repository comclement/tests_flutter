import 'package:flutter/material.dart';
import 'package:tests_flutter/commons/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tests_flutter/router/app_router.dart';
import 'package:tests_flutter/services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.instance.init();
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
