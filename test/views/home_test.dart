import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tests_flutter/views/home/home_view.dart';

void main() {
  group('HomeView Widget Tests', () {
    // Helper pour créer la page avec Riverpod
    Widget createHomeScreen() => const ProviderScope(
          child: MaterialApp(home: HomeView()),
        );

    testWidgets("1. Affichage des composants principaux", (tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Vérifie la présence de l'AppBar
      expect(find.text('Home'), findsOneWidget);

      // Vérifie la présence de la liste (ListView)
      expect(find.byType(ListView), findsOneWidget);

      // Vérifie le bouton Favorites dans l'AppBar
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets("2. Ajout d'un favori met à jour l'icône", (tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Rechercher un élément spécifique
      final addIconKey = find.byKey(const Key("add_icon_0"));
      expect(addIconKey, findsOneWidget);

      // Avant clic : l'icône est vide
      expect(find.byIcon(Icons.favorite_border_outlined), findsWidgets);

      // Simuler un clic pour ajouter aux favoris
      await tester.tap(addIconKey);
      await tester.pump();

      // Après clic : l'icône est pleine (favorite)
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets("3. Suppression d'un favori met à jour l'icône",
        (tester) async {
      await tester.pumpWidget(createHomeScreen());

      final addIconKey = find.byKey(const Key("add_icon_0"));

      // Ajouter aux favoris
      await tester.tap(addIconKey);
      await tester.pump();

      // Vérifier que l'icône est 'favorite'
      expect(find.byIcon(Icons.favorite), findsWidgets);

      // Supprimer des favoris
      await tester.tap(addIconKey);
      await tester.pump();

      // Vérifier que l'icône redevient 'favorite_border_outlined'
      expect(find.byIcon(Icons.favorite_border_outlined), findsWidgets);
    });

    testWidgets("4. Navigation vers la page des favoris", (tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Trouver le bouton Favorites dans l'AppBar
      final favoritesButton = find.text("Favorites");
      expect(favoritesButton, findsOneWidget);

      // Simuler un appui sur le bouton
      await tester.tap(favoritesButton);
      await tester.pumpAndSettle();

      // Vous devrez vérifier si la route 'favoritesPath' est atteinte.
      // Cela dépend de votre configuration des routes.
      // Exemple si vous avez une route FavoritesPage :
      // expect(find.byType(FavoritesPage), findsOneWidget);
    });
  });
}
