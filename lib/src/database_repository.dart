abstract class DatabaseRepository {
  Future<void> init();
  Future<void> set(String collection, String id, dynamic data);
  Future<void> update(String collection, String id, Map<String, dynamic> data);
  Future<dynamic> get(String collection, String id, {dynamic defaultValue});
  Future<bool> exists(String collection, String id);
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  });
  Future<void> delete(String collection, String id);

  // Query-Operationen (für komplexere Abfragen)
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  });

  dynamic get serverTimestamp;
}
