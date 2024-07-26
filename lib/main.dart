import 'package:flutter/material.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/screens/home.dart';
import 'package:store_navigator/utils/data/database.dart';
import 'package:store_navigator/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the db so that tables are created if they haven't been
  await DatabaseHelper().db;

  runApp(
    QueryScope(
      child: MyApp(),
    ),
  );
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
