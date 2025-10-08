import 'database_repository.dart';

class Database {
  late DatabaseRepository prefs;
  late DatabaseRepository secure;
  late DatabaseRepository storage;

  // Shortcuts für Timestamps
  dynamic get stTimestamp => storage.serverTimestamp;
  dynamic get prTimestamp => prefs.serverTimestamp;
  dynamic get seTimestamp => secure.serverTimestamp;

  static Database? _instance;
  static Database get instance {
    if (_instance == null) {
      throw StateError(
        'Database not initialized. Call Databse.initialize() first',
      );
    }
    return _instance!;
  }

  Database._();

  static Future<void> initialize({
    required DatabaseRepository prefRepository,
    required DatabaseRepository secureRepository,
    required DatabaseRepository storageRepository,
  }) async {
    _instance = Database._();
    _instance!.prefs = prefRepository;
    _instance!.secure = secureRepository;
    _instance!.storage = storageRepository;

    await _instance!.prefs.init();
    await _instance!.secure.init();
    await _instance!.storage.init();
  }
}
