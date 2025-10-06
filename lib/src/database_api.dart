import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:database_wrapper/src/database_repository.dart';

class DatabaseApi implements DatabaseRepository {
  final String baseUrl;

  DatabaseApi({required this.baseUrl});

  @override
  Future<void> init() async {
    // Nichts zu tun
  }

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    await http.post(
      Uri.parse('$baseUrl/$collection/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await http.patch(
      // PATCH = partielle Updates
      Uri.parse('$baseUrl/$collection/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    final response = await http.get(Uri.parse('$baseUrl/$collection/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      return defaultValue;
    } else {
      throw Exception('Failed to get document: ${response.statusCode}');
    }
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final response = await http.head(Uri.parse('$baseUrl/$collection/$id'));
    return response.statusCode == 200;
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    final results = await query(collection, where: where);
    return results.isNotEmpty;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await http.delete(Uri.parse('$baseUrl/$collection/$id'));
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    String queryString = '';
    if (where.isNotEmpty) {
      final params = where.entries.map((e) => '${e.key}=${e.value}').join('&');
      queryString = '?$params';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$collection$queryString'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to query collection: ${response.statusCode}');
    }
  }

  @override
  dynamic get serverTimestamp => DateTime.now().toUtc().toIso8601String();
}
