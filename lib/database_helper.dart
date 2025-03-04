import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Database constants
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'my_table';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  late Database _db;

  /// Opens the database (and creates it if it doesn't exist).
  Future<void> init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// SQL code to create the database table.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnAge INTEGER NOT NULL
      )
    ''');
  }

  /// Inserts a row into the database table.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  /// Returns all rows from the table as a list of Maps.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

  /// Returns the number of records in the table.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  /// Updates a row in the database. The row must include the '_id' key to match.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a single row by its ID.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // NEW METHODS
  // ---------------------------------------------------------------------------

  /// Returns the row (Map) matching the provided ID, or null if none found.
  Future<Map<String, dynamic>?> queryRowById(int id) async {
    final results = await _db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Deletes all rows in the table. Returns the number of rows deleted.
  Future<int> deleteAll() async {
    return await _db.delete(table);
  }
}
