import 'package:flutter/material.dart';
import 'database_helper.dart';

// Global database helper instance
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a lighter color scheme from a softer seed color (light blue).
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF90CAF9), // Light Blue shade
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true, // for a more modern, subtle M3 design
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lighter background gradient
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FBFC), // Very light
              Color(0xFFE8F1F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // A smaller, lighter header with simpler style
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(top: 30, bottom: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Text(
                  'Cleaner CRUD App',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main card containing the buttons
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildCrudButton(
                          context,
                          label: 'Insert',
                          onPressed: () => _showInsertDialog(context),
                          icon: Icons.add,
                        ),
                        const SizedBox(height: 12),
                        _buildCrudButton(
                          context,
                          label: 'Query (All Rows)',
                          onPressed: _queryAll,
                          icon: Icons.list,
                        ),
                        const SizedBox(height: 12),
                        _buildCrudButton(
                          context,
                          label: 'Update',
                          onPressed: () => _showUpdateDialog(context),
                          icon: Icons.update,
                        ),
                        const SizedBox(height: 12),
                        _buildCrudButton(
                          context,
                          label: 'Delete (Last Row)',
                          onPressed: _deleteLast,
                          icon: Icons.delete_sweep,
                        ),
                        const Divider(height: 30),
                        _buildCrudButton(
                          context,
                          label: 'Query by ID',
                          onPressed: () => _showQueryByIdDialog(context),
                          icon: Icons.search,
                        ),
                        const SizedBox(height: 12),
                        _buildCrudButton(
                          context,
                          label: 'Delete All',
                          onPressed: _deleteAll,
                          icon: Icons.delete_forever,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget for a modern but lighter ElevatedButton with icon
  Widget _buildCrudButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = isDestructive
        ? Colors.red.shade300
        : colorScheme.primary.withOpacity(0.6);

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        elevation: 1,
        backgroundColor: baseColor,
        foregroundColor: colorScheme.onPrimary.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon ?? Icons.build),
      label: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }

  // --------------------------------------------------------------------------
  // 1) INSERT: Prompt user for name & age, then insert
  // --------------------------------------------------------------------------
  void _showInsertDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Insert New Record'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 0;
              if (name.isNotEmpty && age > 0) {
                final row = {
                  DatabaseHelper.columnName: name,
                  DatabaseHelper.columnAge: age,
                };
                final id = await dbHelper.insert(row);
                debugPrint('Inserted row id: $id');
              }
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2) QUERY ALL: No user input needed, just query all rows
  // --------------------------------------------------------------------------
  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('Query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  // --------------------------------------------------------------------------
  // 3) UPDATE: Prompt for ID, Name, Age, then update that record
  // --------------------------------------------------------------------------
  void _showUpdateDialog(BuildContext context) {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update a Record'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID to Update'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'New Name'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'New Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(idController.text.trim()) ?? -1;
              final newName = nameController.text.trim();
              final newAge = int.tryParse(ageController.text.trim()) ?? 0;

              if (id > 0 && newName.isNotEmpty && newAge > 0) {
                final row = {
                  DatabaseHelper.columnId: id,
                  DatabaseHelper.columnName: newName,
                  DatabaseHelper.columnAge: newAge,
                };
                final rowsAffected = await dbHelper.update(row);
                debugPrint('Updated $rowsAffected row(s)');
              } else {
                debugPrint('Invalid input for update.');
              }
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 4) DELETE (LAST ROW): Uses queryRowCount to find the last row ID
  // --------------------------------------------------------------------------
  void _deleteLast() async {
    final count = await dbHelper.queryRowCount();
    if (count > 0) {
      final rowsDeleted = await dbHelper.delete(count);
      debugPrint('Deleted row $count ($rowsDeleted row(s) affected)');
    } else {
      debugPrint('No rows to delete.');
    }
  }

  // --------------------------------------------------------------------------
  // 5) QUERY BY ID: Prompt for ID to search
  // --------------------------------------------------------------------------
  void _showQueryByIdDialog(BuildContext context) {
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Query by ID'),
        content: SizedBox(
          width: 200,
          child: TextField(
            controller: idController,
            decoration: const InputDecoration(labelText: 'Enter ID'),
            keyboardType: TextInputType.number,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(idController.text.trim()) ?? -1;
              if (id > 0) {
                final row = await dbHelper.queryRowById(id);
                if (row != null) {
                  debugPrint('Record found: $row');
                } else {
                  debugPrint('No record found with ID=$id');
                }
              } else {
                debugPrint('Invalid ID for query.');
              }
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 6) DELETE ALL
  // --------------------------------------------------------------------------
  void _deleteAll() async {
    final rowsDeleted = await dbHelper.deleteAll();
    debugPrint('All records deleted, total: $rowsDeleted');
  }
}
