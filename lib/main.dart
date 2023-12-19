import 'package:se420/maze_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';

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
  List<Cell> expandedCells = [];
  bool solveButtonClicked = false;

  double solutionCost = 0.0;
  bool solutionFound = false;


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

  void onNodeExpanded(Cell cell) {
    setState(() {
      expandedCells.add(cell);
    });
  }

  /// Solve the maze using A* algorithm
  Future<void> solveMaze() async {

    expandedCells.clear();

    // Ensure that the maze is generated before solving
    if (maze.isEmpty) {
      return;
    }

    // Create an AStarSolver instance and find the solution
    AStarSolver aStarSolver = AStarSolver(maze);
    solutionPath = await aStarSolver.findPath(onNodeExpanded);

    // Check if a solution was found
    if (solutionPath.isNotEmpty) {
      solutionFound = true;
      // Calculate the cost
      solutionCost = calculateSolutionCost(solutionPath);
    } else {
      solutionFound = false;
    }

    solveButtonClicked = true;
    // Trigger a repaint to update the UI with the solution
    setState(() {});
  }

  double calculateSolutionCost(List<Cell> path) {
    // Implement the logic to calculate the cost of the path
    // For example, summing the costs of each move
    double cost = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      cost += cellCost(path[i], path[i + 1]);
    }
    return cost;
  }

  double cellCost(Cell a, Cell b) {
    // Check if the move is horizontal (right or left)
    if (a.y == b.y) {
      return 2.0; // Cost for moving right or left
    }
    // Check if the move is vertical (up or down)
    if (a.x == b.x) {
      return 1.0; // Cost for moving up or down
    }
    return 0.0; // Return 0.0 if it's neither (which should not happen in a valid maze)
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
                    expandedCells: [],
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
            if (solutionFound)
              Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 100),
                      child: CustomPaint(
                        size: const ui.Size(200, 200),
                        key: UniqueKey(),
                        isComplex: true,
                        painter: MazeDriverCanvas(
                          expandedCells: expandedCells,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0),
                    child: Text("Solution Cost: $solutionCost",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            if (!solutionFound && solveButtonClicked)
              const Center(
                child: Text(
                  "No Solution",
                  style: TextStyle(color: Colors.red),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class AStarSolver {
  List<List<Cell>> maze;

  AStarSolver(this.maze);

  Future<List<Cell>> findPath(Function(Cell) onExpand) async {
    // A* algorithm implementation

    // Define start and goal cells
    Cell startCell = maze.first.first;
    Cell goalCell = maze.last.last;
    int expandedNodes = 0;

    // Define a priority queue for open set
    var openSet = PriorityQueue<Node>();
    openSet.add(Node(
        cell: startCell,
        cost: 0,
        heuristic: manhattanDistance(startCell, goalCell)));

    // Define a map for tracking costs to reach each cell
    Map<Cell, double> costSoFar = {startCell: 0};

    // Define a map for tracking paths
    Map<Cell, Cell?> cameFrom = {startCell: null};

    while (openSet.isNotEmpty && expandedNodes < 10) {
      var current = openSet.removeFirst().cell;
      expandedNodes++;
      onExpand(current);

      // Goal check
      if (current == goalCell) break;

      // Explore neighbors
      for (var next in getNeighbors(current)) {
        double newCost = costSoFar[current]! + cellCost(current, next);

        if (!costSoFar.containsKey(next) || newCost < costSoFar[next]!) {
          costSoFar[next] = newCost;
          double priority = newCost + manhattanDistance(next, goalCell);
          openSet.add(Node(cell: next, cost: newCost, heuristic: priority));
          cameFrom[next] = current;
        }
      }
    }

    // Reconstruct path
    return reconstructPath(cameFrom, startCell, goalCell);
  }

  List<Cell> reconstructPath(Map<Cell, Cell?> cameFrom, Cell start, Cell goal) {
    List<Cell> path = [];
    Cell? current = goal;

    // Assuming each cell is a square of size `cellSize`
    double cellSize = 1.0; // Replace 1.0 with the actual size of a cell

    while (current != start && current != null) {
      // Adjust the cell's coordinates to the center
      Cell centeredCell = Cell(
        x: current!.x + cellSize / 2,
        y: current.y + cellSize / 2,
        top: current.top,
        left: current.left,
        bottom: current.bottom,
        right: current.right,
      );

      path.add(centeredCell);
      current = cameFrom[current];
    }

    // Adjust the start cell's coordinates to the center
    Cell centeredStartCell = Cell(
      x: start.x + cellSize / 2,
      y: start.y + cellSize / 2,
      top: start.top,
      left: start.left,
      bottom: start.bottom,
      right: start.right,
    );

    if (current == null) {
      // No valid path to the start cell was found
      return [];
    }

    path.add(centeredStartCell);
    return path.reversed.toList();
  }


  double manhattanDistance(Cell a, Cell b) {
    print((a.x - b.x).abs() + (a.y - b.y).abs());
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  double cellCost(Cell a, Cell b) {
    // Check if the move is horizontal (right or left)
    if (a.y == b.y) {
      return 2.0; // Cost for moving right or left
    }
    // Check if the move is vertical (up or down)
    if (a.x == b.x) {
      return 1.0; // Cost for moving up or down
    }
    // This condition should never happen in a 4-directional grid
    throw Exception("Invalid move detected");
  }


  Iterable<Cell> getNeighbors(Cell cell) {
    List<Cell> neighbors = [];
    int x = cell.x.toInt();
    int y = cell.y.toInt();

    // Check if the cell above is accessible
    if (y > 0 && !cell.top && !maze[y - 1][x].bottom) {
      neighbors.add(maze[y - 1][x]);
    }

    // Check if the cell to the right is accessible
    if (x < maze[0].length - 1 && !cell.right && !maze[y][x + 1].left) {
      neighbors.add(maze[y][x + 1]);
    }

    // Check if the cell below is accessible
    if (y < maze.length - 1 && !cell.bottom && !maze[y + 1][x].top) {
      neighbors.add(maze[y + 1][x]);
    }

    // Check if the cell to the left is accessible
    if (x > 0 && !cell.left && !maze[y][x - 1].right) {
      neighbors.add(maze[y][x - 1]);
    }

    return neighbors;
  }
}

class Node implements Comparable<Node> {
  final Cell cell;
  final double cost;
  final double heuristic;

  Node({required this.cell, required this.cost, required this.heuristic});

  @override
  int compareTo(Node other) {
    return (this.cost + this.heuristic).compareTo(other.cost + other.heuristic);
  }
}
