// local_storage.dart

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage{
  static const String _box = 'app_storage';

  // Initialiseer Hive en open de box
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_box);
  }

  // Sla een waarde op
  static Future<void> save(String key, dynamic value) async {
    var box = Hive.box(_box);
    await box.put(key, value);
  }

  // Verkrijg een waarde
  static dynamic get(String key) {
    var box = Hive.box(_box);
    return box.get(key);
  }

  // Verwijder een waarde
  static Future<void> delete(String key) async {
    var box = Hive.box(_box);
    await box.delete(key);
  }

  // Leeg de box
  static Future<void> clear() async {
    var box = Hive.box(_box);
    await box.clear();
  }
}

