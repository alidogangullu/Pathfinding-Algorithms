import 'package:se420/maze_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;

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
      home: const MyHomePage(title: 'SE420 Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<List<Cell>> maze = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();
      generateMaze();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Generate the maze
  void generateMaze() {
    int width = 3;
    int height = 3;
    List<List<Cell>> localMaze = generate(width: width, height: height);
    
    List<MazeBoxClass>? mazeBoxes = localMaze
        .expand((element) => element)
        .map((e) => MazeBoxClass(e),)
        .toList();
    
    //List<MazeBoxClass> mazes = List<MazeBoxClass>.from(mazeBoxes);
    //MazeBoxClass firstMaze = mazes.removeAt(0);


    setState(() {
      maze = localMaze;
      //mazeSolution = solution;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generateMaze,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 100),
                child: CustomPaint(
                  size: const ui.Size(200, 400),
                  key: UniqueKey(),
                  isComplex: true,
                  painter: MazeDriverCanvas(
                    controller: _controller,
                    maze: maze,
                    blockSize: 75,
                    //solution: this.mazeSolution,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MazeBoxClass {
  Cell cell;
  bool blok = false;
  late Offset offset;

  MazeBoxClass(this.cell){
    offset = Offset(cell.x, cell.y);
  }

}
