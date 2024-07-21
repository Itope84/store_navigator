import 'package:flutter/material.dart';
import 'package:store_navigator/home.dart';
import 'package:store_navigator/utils/data/database.dart';
import 'package:store_navigator/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper().db;

  final List<Map<String, dynamic>> tables = await db
      .rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table';");

  print('Table structures:');
  for (var table in tables) {
    print('Table: ${table['name']}');
    print('Create SQL: ${table['sql']}');
    print('---');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoomable Map App',
      theme: createTheme(),
      home: HomeScreen(),
    );
  }
}
