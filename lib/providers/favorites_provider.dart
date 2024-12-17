import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tests_flutter/helpers/shared_prefs_helper.dart';

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesProvider, List<int>>(
        (ref) => FavoritesProvider());

class FavoritesProvider extends StateNotifier<List<int>> {
  SharedPrefsHelper helper = SharedPrefsHelper();

  FavoritesProvider() : super([]) {
    state = helper.getIntList("favorites");
  }

  void addFavorite(int itemIndex) async {
    if (!state.contains(itemIndex)) {
      state = [...state, itemIndex];
      await helper.setIntList("favorites", state);
    }
  }

  void deleteFavorite(int itemIndex) async {
    state = state.where((item) => item != itemIndex).toList();
    await helper.setIntList("favorites", state);
  }
}
