import 'package:hive_flutter/hive_flutter.dart';
import 'package:database_wrapper/src/database_repository.dart';

class DatabaseHive implements DatabaseRepository {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('settings');
  }

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    await box.put(id, data);
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    final existing = box.get(id) ?? {};
    final updated = {...existing, ...data};
    await box.put(id, updated);
  }

  @override
  Future<dynamic> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    final data = box.get(id, defaultValue: defaultValue);
    if (data is Map) {
      return data.cast<String, dynamic>();
    } else {
      return data;
    }
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    return box.containsKey(id);
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    for (var item in box.values) {
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
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);
    await box.delete(id);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    final Box box = Hive.isBoxOpen(collection)
        ? Hive.box(collection)
        : await Hive.openBox(collection);

    if (where.isEmpty) {
      return box.values.map((item) {
        final data = (item as Map).cast<String, dynamic>();
        return data;
      }).toList();
    }

    return box.values
        .where((item) {
          final map = item as Map;
          for (var entry in where.entries) {
            if (map[entry.key] != entry.value) return false;
          }
          return true;
        })
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
  }

  @override
  dynamic get serverTimestamp => DateTime.now().toIso8601String();
}
