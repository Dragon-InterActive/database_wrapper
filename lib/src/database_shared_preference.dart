import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:database_wrapper/src/database_repository.dart';

class DatabaseSharedPreference implements DatabaseRepository {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getKey(String collection, String id) => '$collection:$id';

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    await init();
    final key = _getKey(collection, id);
    await _prefs!.setString(key, jsonEncode(data));
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await init();
    final key = _getKey(collection, id);
    final existing = await await get(collection, id) ?? {};
    final updated = {...existing, ...data};
    await _prefs!.setString(key, jsonEncode(updated));
  }

  @override
  Future<dynamic> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    await init();
    final key = _getKey(collection, id);
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return defaultValue;
    return jsonDecode(jsonString);
  }

  @override
  Future<bool> exists(String collection, String id) async {
    await init();
    final key = _getKey(collection, id);
    return _prefs!.containsKey(key);
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    await init();
    final items = await query(collection);
    for (var item in items) {
      bool matches = true;
      for (var entry in where.entries) {
        if (item[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await init();
    final key = _getKey(collection, id);
    await _prefs!.remove(key);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    await init();
    final prefix = '$collection:';
    final keys = _prefs!.getKeys().where((key) => key.startsWith(prefix));

    final items = <Map<String, dynamic>>[];
    for (var key in keys) {
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        final item = jsonDecode(jsonString) as Map<String, dynamic>;
        items.add(item);
      }
    }

    if (where.isEmpty) {
      return items;
    }

    return items.where((item) {
      for (var entry in where.entries) {
        if (item[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
  }

  @override
  dynamic get serverTimestamp => DateTime.now().toIso8601String();
}
