import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_data.dart';

class StorageService {
  static const String boxName = 'gameBox';
  static const String _key = 'gameData';

  Box get _box => Hive.box(boxName);

  GameData loadGameData() {
    final raw = _box.get(_key);
    if (raw == null) return GameData.initial();
    try {
      return GameData.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return GameData.initial();
    }
  }

  Future<void> saveGameData(GameData data) async {
    await _box.put(_key, data.toJson());
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
