import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_wrapper/src/database_repository.dart';

class DatabaseFirestore implements DatabaseRepository {
  final FirebaseOptions firebaseOptions;

  DatabaseFirestore({required this.firebaseOptions});

  @override
  Future<void> init() async {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    await FirebaseFirestore.instance.collection(collection).doc(id).set(data);
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .update(data);
  }

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();
    return doc.exists
        ? doc.data()
        : defaultValue
        ? defaultValue
        : null;
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();
    return doc.exists;
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    Query query = FirebaseFirestore.instance.collection(collection);
    for (var entry in where.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    final snapshot = await query.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await FirebaseFirestore.instance.collection(collection).doc(id).delete();
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    Query query = FirebaseFirestore.instance.collection(collection);

    // Filter hinzufügen
    for (var entry in where.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Document ID hinzufügen
      return data;
    }).toList();
  }

  @override
  dynamic get serverTimestamp => FieldValue.serverTimestamp();
}
