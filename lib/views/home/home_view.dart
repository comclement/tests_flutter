import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tests_flutter/commons/constants.dart';
import 'package:tests_flutter/providers/favorites_provider.dart';
import 'package:tests_flutter/services/notifications_service.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  late List<int> favorites;

  @override
  void initState() {
    super.initState();
    NotificationsService.setupNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: const Text("Home"),
        actions: [
          TextButton.icon(
            onPressed: () => context.pushNamed(favoritesPath),
            label: const Text("Favorites"),
            icon: const Icon(Icons.favorite),
          )
        ],
        centerTitle: false,
      ),
      body: _listItemHome(),
    );
  }

  Widget _listItemHome() {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        itemCount: 100,
        cacheExtent: 20.0,
        itemBuilder: (_, index) {
          return _itemHome(index);
        });
  }

  Widget _itemHome(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[index % Colors.primaries.length],
        ),
        title: Text("Item $index", key: Key("text_$index")),
        trailing: IconButton(
            key: Key("add_icon_$index"),
            onPressed: !favorites.contains(index)
                ? () {
                    ref
                        .read(favoritesNotifierProvider.notifier)
                        .addFavorite(index);
                    NotificationsService().sendPushMessage("add");
                  }
                : () {
                    ref
                        .read(favoritesNotifierProvider.notifier)
                        .deleteFavorite(index);
                    NotificationsService().sendPushMessage("remove");
                  },
            icon: Icon(favorites.contains(index)
                ? Icons.favorite
                : Icons.favorite_border_outlined)),
      ),
    );
  }
}
