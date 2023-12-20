import 'package:se420/app/maze_edit_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SE420 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const SolutionScreen(title: 'SE420 Project'),
      home: const MazeEdit(title: 'SE420 Project'),
    );
  }
}
