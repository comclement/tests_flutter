import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tests_flutter/providers/favorites_provider.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {
  late List<int> favorites;

  @override
  Widget build(BuildContext context) {
    favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text("Favorites"),
      ),
      body: _listItemFavorites(),
    );
  }

  Widget _listItemFavorites() {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        itemCount: favorites.length,
        cacheExtent: 20,
        itemBuilder: (_, index) {
          int itemIndex = favorites[index];
          return _itemFavorite(itemIndex);
        });
  }

  Widget _itemFavorite(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.primaries[index % Colors.primaries.length],
          ),
          title: Text("Item $index", key: Key("favorite_text_$index")),
          trailing: IconButton(
              key: Key("remove_icon_$index"),
              onPressed: () => ref
                  .read(favoritesNotifierProvider.notifier)
                  .deleteFavorite(index),
              icon: const Icon(Icons.close))),
    );
  }
}
