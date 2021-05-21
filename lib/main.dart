import 'package:flutter/material.dart';
import 'package:flutter_game_2048/src/ui/screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 2048 Game',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MainScreen(),
    );
  }
}
