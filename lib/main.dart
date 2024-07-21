import 'package:flutter/material.dart';
import 'package:store_navigator/home.dart';
import 'package:store_navigator/store_map.dart';
import 'package:store_navigator/utils/theme.dart';
import 'zoomable_map.dart';

void main() {
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
