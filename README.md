# Mettre en place send notifications push front

## Pour utiliser l'api d'envoi des notifications push avec Firebase Messaging:

- Aller dans Firebase > Project settings > Cloud Messaging
- Firebase Cloud Messaging API (V1) > Manage Service Accounts
- Une fois dans le Google Cloud Console:
  - IAM & Admin > Service Accounts > Click sur le compte admin (si pas de compte, en créer un)
  - KEYS > ADD KEY > Télécharger la clé en format JSON et mettre ce fichier dans le projet (attention à bien le mettre dans le .gitignore)
