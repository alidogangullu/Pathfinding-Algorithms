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
  List<Cell> solutionPath = [];
  bool solveButtonClicked = false;

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

  /// Solve the maze using A* algorithm
  Future<void> solveMaze() async {
    // Ensure that the maze is generated before solving
    if (maze.isEmpty) {
      return;
    }

    // Create an AStarSolver instance and find the solution
    AStarSolver aStarSolver = AStarSolver(maze);
    solutionPath = await aStarSolver.findPath();

    solveButtonClicked = true;
    // Trigger a repaint to update the UI with the solution
    setState(() {});
  }

  /// Generate the maze
  void generateMaze() {
    int width = 3;
    int height = 3;
    List<List<Cell>> localMaze = generate(width: width, height: height);

    setState(() {
      maze = localMaze;
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
        onPressed: solveMaze,
        backgroundColor: Colors.green,
        child: const Icon(Icons.play_arrow),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 35),
                child: CustomPaint(
                  size: const ui.Size(200, 200),
                  key: UniqueKey(),
                  isComplex: true,
                  painter: MazeDriverCanvas(
                    solutionPath: [],
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
            if (solutionPath.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: CustomPaint(
                    size: const ui.Size(200, 200),
                    key: UniqueKey(),
                    isComplex: true,
                    painter: MazeDriverCanvas(
                      controller: _controller,
                      maze: maze,
                      blockSize: 75,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      solutionPath: solutionPath,
                    ),
                  ),
                ),
              ),
            if (solutionPath.isEmpty && solveButtonClicked)
              const Center(child: Text("No Solution", style: TextStyle(color: Colors.red),),)
          ],
        ),
      ),
    );
  }
}

class AStarSolver {
  List<List<Cell>> maze;

  AStarSolver(this.maze);

  Future<List<Cell>> findPath() async {
    // Implementation of A* algorithm to find the solution path
    // Modify this function based on your maze structure and logic

    // Simulating some asynchronous work
    await Future.delayed(const Duration(seconds: 1));

    // Placeholder - Replace this with your actual A* algorithm implementation
    // The solutionPath should be a list of cells representing the path
    // from the start to the end in the maze.

    List<Cell> solutionPath = [];

    // Example: Mark the top-left and bottom-right cells as the start and end
    Cell startCell = maze.first.first;
    Cell endCell = maze.last.last;

    int currentX = startCell.x.toInt();
    int currentY = startCell.y.toInt();

    while (currentX != endCell.x.toInt() || currentY != endCell.y.toInt()) {
      // Add the cell to the middle of the cell
      solutionPath.add(Cell(
        x: currentX.toDouble() + 0.5,
        y: currentY.toDouble() + 0.5,
        top: true,    // Modify as needed based on your maze structure
        left: true,   // Modify as needed based on your maze structure
        bottom: true, // Modify as needed based on your maze structure
        right: true,  // Modify as needed based on your maze structure
      ));

      // Move towards the endCell, considering walls
      if (currentX < endCell.x.toInt() && !maze[currentY][currentX].right &&
          !maze[currentY][currentX + 1].left) {
        currentX++;
      } else if (currentX > endCell.x.toInt() && !maze[currentY][currentX].left &&
          !maze[currentY][currentX - 1].right) {
        currentX--;
      } else if (currentY < endCell.y.toInt() && !maze[currentY][currentX].bottom &&
          !maze[currentY + 1][currentX].top) {
        currentY++;
      } else if (currentY > endCell.y.toInt() && !maze[currentY][currentX].top &&
          !maze[currentY - 1][currentX].bottom) {
        currentY--;
      } else {
        //no solution
        solutionPath.clear();
        break;
      }
    }

    if (solutionPath.isNotEmpty) {
      // Add the final cell after the loop
      solutionPath.add(Cell(
        x: endCell.x.toDouble() + 0.5,
        y: endCell.y.toDouble() + 0.5,
        top: true,
        // Modify as needed based on your maze structure
        left: true,
        // Modify as needed based on your maze structure
        bottom: true,
        // Modify as needed based on your maze structure
        right: true, // Modify as needed based on your maze structure
      ));
    }

    return solutionPath;
  }

}
