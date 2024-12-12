import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  Future<void> saveData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des données : $e');
    }
  }

  Future<String?> getData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données : $e');
    }
  }

  Future<void> deleteData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des données : $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression de toutes les données : $e');
    }
  }
}
