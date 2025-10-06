# database_wrapper

this package is a database wrapper which main function is to handle 3 different datastorage types.

1. Local Storage (Hive or SharedPreferences may be SQLite)
2. Secure Storage (Important for Tokens)
3. Server Storage Databases (Firestore, Supabase, AppWrite etc. or simply APIs like GraphQL)

## Implemented Repositories

- SecureStorage
- SharedPreferences
- Hive
- Firebase - Firestore
- Api
- Mock - Test Pattern

## Getting started

yaml

```yaml
dependencies:
  database_repo:
    git:
      url: https://github.com/Dragon-InterActive/database_wrapper.git
      ref: v0.0.1
```

## Usage

Create your in lib/ subdirectories like you need, a database_config.dart and embed the Repo Package to you project:

database_config.dart

```dart
import 'package:database_wrapper/database_wrapper.dart';
```

initialize and create your global db variable like this:

database_config.dart

```dart
Future<void> initDB() async {
  await Database.initialize(
    prefsRepository: DatabaseHive(),
    secureRepository: DatabaseSecureStorage(),
    storageRepository: DatabaseApi(baseUrl: 'https://api.example.com'),
  );
}

final db = Database.instance;
```

Your main() must be **async** now.

main.dart

```dart
import 'lib/your_path/database_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDB();
  runApp(const MyApp());
}
```

Now you can use db globally in your app. All you need to do is, import your database_config.dart where you need access to your global db variable.

## CRUD Examples

All functions are same, Create, Read, Update and Delete for all connections.

collection, doc, data

### Write data to storage (Create)

SecureStorage

```dart
await db.secure.set('users', 'abc123', {'name': 'Maxi Million'});
```

SharedPreferences / Hive

```dart
await db.prefs.set('users', 'abc123', {'name': 'Maxi Million'});
```

Firestore / AppWrite / Api / Supabase etc.

```dart
await db.storage.set('users', 'abc123', {'name': 'Maxi Million'});
```

### Update storage data (Update)

SecureStorage

```dart
await db.secure.update('users', 'abc123', {'name': 'Rich Maximillion'});
```

SharedPreferences

```dart
await db.prefs.update('users', 'abc123', {'name': 'Rich Maximillion'});
```

Firestore

```dart
await db.storage.update('users', 'abc123', {'name': 'Rich Maximillion'});
```

### Read data from storage (Read)

SecureStorage

```dart
var user = await db.secure.get('users', 'abc123', defaultValue: 'Max');
```

SharedPreferences

```dart
var user = await db.prefs.get('users', 'abc123', defaultValue: 'Max');
```

Firestore

```dart
var user = await db.storage.get('users', 'abc123', defaultValue: 'Max');
```

### Delete data from storage (Delete)

SecureStorage

```dart
await db.secure.delete('users', 'abc123');
```

SharedPreferences

```dart
await db.prefs.delete('users', 'abc123');
```

Firestore

```dart
await db.storage.delete('users', 'abc123');
```

## Working with subcollection

### create / update

that is easy

```dart
await db.storage.set('users/user123/orders', 'order001', {
  'product': 'Laptop',
  'price': 999.99,
});
```

this will create

- _users_ collection (if not exists)
- _user123_ document (if not exists)
- _orders_ subcollection (if not exists)
- _order001_ document

### Delete with Subcollection

You need to delete collection by collection

```dart
await db.storage.delete('users/user123/orders', 'order001');
await db.storage.delete('users', 'user123');
```

## available methods

- set(String collection, String id, dynamic data)
- get(String collection, String id, {dynamic defaultValue})
- update(String collection, String id, Map<String, dynamic> data)
- delete(String collection, String id)
- exists(String collection, String id)
- existsWhere(String collection, {required Map<String, dynamic> where})
- query(String collection, {Map<String, dynamic> where = const{},})

## ServerTimestamp

Each database system has its own Timestamp method, so we created this way:

- stTimestamp => storage.serverTimestamp;
- prTimestamp => prefs.serverTimestamp;
- seTimestamp => secure.serverTimestamp;

now you can use db.stTimestamp to initiate e.g. Firestore's FieldValue.serverTimestamp. This makes it easier for you to handle multiple database systems with sane methods.

## Extend this Wrapper

create in your project a folder for your Database-Handler.

/lib/core/database/database_sqlite.dart

```dart
// import the sqlite
import 'package:sqflite/sqflite.dart';
// import path
import 'package:path/path.dart';
// import the wrapper library
import 'package:database_wrapper/database_wrapper.dart';

class DatabaseSqlite implements DatabaseRepository {
  final String databaseName;
  Database? _db;

  DatabaseSqlite({this.databaseName = 'app_database.db'});

  @override
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);
    
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // create tables if needed
      },
    );
  }

  @override
  dynamic get serverTimestamp => DateTime.now().toIso8601String();

  @override
  Future<void> set(String collection, String id, dynamic data) async {
    await _db!.insert(
      collection,
      {'id': id, ...data as Map<String, dynamic>},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(String collection, String id, Map<String, dynamic> data) async {
    await _db!.update(
      collection,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id, {dynamic defaultValue}) async {
    final result = await _db!.query(
      collection,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : defaultValue;
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final result = await _db!.query(
      collection,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> existsWhere(String collection, {required Map<String, dynamic> where}) async {
    final results = await query(collection, where: where);
    return results.isNotEmpty;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await _db!.delete(
      collection,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> query(String collection, {Map<String, dynamic> where = const {}}) async {
    if (where.isEmpty) {
      return await _db!.query(collection);
    }
    
    final whereClause = where.keys.map((key) => '$key = ?').join(' AND ');
    final whereArgs = where.values.toList();
    
    return await _db!.query(
      collection,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }
}
```

and in your database_config.dart

```dart
Future<void> initDB() async {
  await Database.initialize(
    prefsRepository: DatabaseHive(),
    secureRepository: DatabaseSecureStorage(),
    storageRepository: DatabaseSqlite(databaseName: 'my_app.db'),
  );
}
```
