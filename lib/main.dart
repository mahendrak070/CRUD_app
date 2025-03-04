import 'package:flutter/material.dart';
import 'database_helper.dart';

// Use a global instance of DatabaseHelper for simplicity.
// In a production app, you could use a service locator or Provider.
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database before running the app
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sqflite'),
      ),
      body: Center(
        child: Container(
          // Add a border and padding to enhance UI
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: _insert,
                child: const Text('Insert'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _query,
                child: const Text('Query'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _update,
                child: const Text('Update'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _delete,
                child: const Text('Delete (Last Row)'),
              ),
              const SizedBox(height: 25),
              // NEW BUTTONS BELOW
              ElevatedButton(
                onPressed: _queryById,
                child: const Text('Query by ID = 1'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteAll,
                child: const Text('Delete All'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // Button onPressed handlers
  // -----------------------------

  void _insert() async {
    // Insert a new row. For demo, we'll use static values.
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23
    };
    final id = await dbHelper.insert(row);
    debugPrint('Inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('Query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  void _update() async {
    // For example, update the row with ID=1
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('Updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Delete the "last" row based on rowCount
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    debugPrint('Deleted $rowsDeleted row(s), Row $id');
  }

  // NEW METHODS

  /// Demonstrates how to query for a specific row by ID.
  void _queryById() async {
    final row = await dbHelper.queryRowById(1);
    if (row != null) {
      debugPrint('Record found: $row');
    } else {
      debugPrint('No record found with ID = 1');
    }
  }

  /// Deletes all rows from the database.
  void _deleteAll() async {
    final rowsDeleted = await dbHelper.deleteAll();
    debugPrint('All records deleted, total: $rowsDeleted');
  }
}
