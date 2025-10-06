import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:database_wrapper/src/database_repository.dart';

class DatabaseSecureStorage implements DatabaseRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> init() async {
    // Keine Initialisierung nötig
  }

  String _getKey(String collection, String id) => '$collection:$id';

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    final key = _getKey(collection, id);
    await _storage.write(key: key, value: jsonEncode(data));
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final key = _getKey(collection, id);
    final existing = await get(collection, id) ?? {};
    final updated = {...existing, ...data};
    await _storage.write(key: key, value: jsonEncode(updated));
  }

  @override
  Future<dynamic> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    final key = _getKey(collection, id);
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return defaultValue;
    return jsonDecode(jsonString);
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final key = _getKey(collection, id);
    return await _storage.containsKey(key: key);
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
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
    final key = _getKey(collection, id);
    await _storage.delete(key: key);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    final prefix = '$collection:';
    final allData = await _storage.readAll();

    final items = <Map<String, dynamic>>[];
    for (var entry in allData.entries) {
      if (entry.key.startsWith(prefix)) {
        final item = jsonDecode(entry.value) as Map<String, dynamic>;
        items.add(item);
      }
    }

    if (where.isEmpty) return items;

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
