import 'package:database_wrapper/src/database_repository.dart';

class MockDatabase implements DatabaseRepository {
  final Map<String, Map<String, Map<String, dynamic>>> _data = {};

  @override
  Future<void> init() async {
    // Nichts zu tun
  }

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    _data.putIfAbsent(collection, () => {});
    _data[collection]![id] = data;
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    _data.putIfAbsent(collection, () => {});
    final existing = _data[collection]![id] ?? <String, dynamic>{};
    final updated = {...existing, ...data};
    _data[collection]![id] = updated;
  }

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    return _data[collection]?[id] ?? defaultValue;
  }

  @override
  Future<bool> exists(String collection, String id) async {
    return _data[collection]?.containsKey(id) ?? false;
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    if (!_data.containsKey(collection)) return false;

    final collectionData = _data[collection]!;

    for (var item in collectionData.values) {
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
    _data[collection]?.remove(id);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    if (!_data.containsKey(collection)) return [];

    final collectionData = _data[collection]!;

    if (where.isEmpty) {
      return collectionData.values.toList();
    }

    return collectionData.values.where((item) {
      for (var entry in where.entries) {
        if (item[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
  }

  @override
  dynamic get serverTimestamp => DateTime.now().toIso8601String();
}
