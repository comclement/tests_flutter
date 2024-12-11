import 'dart:convert';

import 'package:tests_flutter/services/shared_prefs_service.dart';

class SharedPrefsHelper {
  Future<void> setIntList(String key, List<int> list) async {
    final jsonString = jsonEncode(list);
    await SharedPrefsService.instance.set<String>(key, jsonString);
  }

  List<int> getIntList(String key) {
    final jsonString = SharedPrefsService.instance.get<String>(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<int>();
  }
}
