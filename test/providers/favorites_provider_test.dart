import 'package:mockito/annotations.dart';
import 'package:tests_flutter/helpers/shared_prefs_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tests_flutter/providers/favorites_provider.dart';
import 'package:tests_flutter/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/favorites_provider_test.mocks.dart';

@GenerateMocks([SharedPrefsHelper])
void main() {
  group("Testing favorites provider", () {
    late MockSharedPrefsHelper mockHelper;
    late ProviderContainer container;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await SharedPrefsService.instance.init();
    });

    setUp(() {
      mockHelper = MockSharedPrefsHelper();
      when(mockHelper.getIntList(any)).thenReturn([]);
      when(mockHelper.setIntList(any, any)).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          favoritesNotifierProvider
              .overrideWith((ref) => FavoritesProvider()..helper = mockHelper),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state devrait être vide', () {
      final state = container.read(favoritesNotifierProvider);
      expect(state, []);
    });

    test('Ajout d\'un favori met à jour l\'état et appelle SharedPrefsHelper',
        () async {
      final notifier = container.read(favoritesNotifierProvider.notifier);

      notifier.addFavorite(1);

      expect(container.read(favoritesNotifierProvider), [1]);
      verify(await mockHelper.setIntList(any, any)).called(1);
    });

    test(
        'Suppression d\'un favori met à jour l\'état et appelle SharedPrefsHelper',
        () async {
      final notifier = container.read(favoritesNotifierProvider.notifier);

      notifier.addFavorite(1);
      notifier.deleteFavorite(1);

      expect(container.read(favoritesNotifierProvider), []);
      verify(mockHelper.setIntList("favorites", [])).called(1);
    });

    test('Ne pas ajouter un favori s\'il est déjà présent', () async {
      final notifier = container.read(favoritesNotifierProvider.notifier);

      notifier.addFavorite(1);
      notifier.addFavorite(1);

      expect(container.read(favoritesNotifierProvider), [1]);
      verify(mockHelper.setIntList("favorites", [1])).called(1);
    });
  });
}
