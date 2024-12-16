# Tests flutter sur les notifications push et tests unitaires

## Pour utiliser l'api d'envoi des notifications push avec Firebase Messaging côté app:

- Aller dans Firebase > Project settings > Cloud Messaging
- Firebase Cloud Messaging API (V1) > Manage Service Accounts
- Une fois dans le Google Cloud Console:
  - IAM & Admin > Service Accounts > Click sur le compte admin (si pas de compte, en créer un)
  - KEYS > ADD KEY > Télécharger la clé en format JSON et mettre ce fichier dans le projet (attention à bien le mettre dans le .gitignore)

## Partie tests unitaires:

- Ajout de packages pour lancer les tests:
  - Pour les tests autonomes du code Flutter sur vos appareils ou émulateurs ajoutez integration_test : flutter pub add --dev --sdk=flutter integration_test
  - Pour une API avancée permettant de tester les applications Flutter exécutées sur des appareils réels ou des émulateurs, ajoutez flutter_driver : flutter pub add --dev --sdk=flutter flutter_driver
  - Pour les outils de test généraux, ajoutez test : flutter pub add --dev test
  - On peut ajouter le package mockito pour faire des tests avec du mock pour simuler le comportement de certaines parties: flutter pub add mockito
