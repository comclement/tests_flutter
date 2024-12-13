import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  String sendNotifsUrl;

  EnvConfig({
    required this.sendNotifsUrl,
  });
}

class EnvService {
  static final EnvService _singleton = EnvService._internal();

  factory EnvService() {
    return _singleton;
  }

  EnvService._internal();

  final EnvConfig _envService = EnvConfig(
    sendNotifsUrl: "",
  );

  Future<void> initEnvService() async {
    await dotenv.load(fileName: ".env");

    _envService.sendNotifsUrl = dotenv.env["SEND_NOTIFS_URL"] ?? "";
  }

  String get getSendNotifsUrl => _envService.sendNotifsUrl;
}
