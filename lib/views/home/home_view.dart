import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tests_flutter/commons/constants.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: const Text("Home"),
      ),
      body: Center(
        child: TextButton(
            onPressed: () => context.pushNamed(favoritesPath),
            child: const Text("Go favorites")),
      ),
    );
  }
}
