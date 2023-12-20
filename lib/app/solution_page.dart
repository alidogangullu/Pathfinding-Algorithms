import 'package:se420/algorithms.dart';
import 'package:se420/maze_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;

class SolutionScreen extends StatefulWidget {
  const SolutionScreen(
      {super.key,
      required this.title,
      required this.maze,
      required this.isUniformCost,
      required this.startCell,
      required this.goalCell});
  final String title;
  final List<List<Cell>> maze;
  final Cell startCell;
  final Cell goalCell;
  final bool isUniformCost;

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Cell> solutionPath = [];
  List<Cell> expandedCells = [];
  int solutionCost = 0;

  List<Cell> partOfExpandedCells = [];
  bool solveButtonClicked = false;
  bool solutionFound = false;
  bool showSolution = false;

  @override
  void initState() {
    super.initState();

    print(widget.goalCell.x);
    print(widget.goalCell.y);

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Solve the maze using A* algorithm
  Future<void> solveMaze() async {
    expandedCells.clear();

    // Ensure that the maze is generated before solving
    if (widget.maze.isEmpty) {
      return;
    }

    if (widget.isUniformCost) {
      UniformCostSolver uniformCostSolver = UniformCostSolver(widget.maze,widget.startCell,widget.goalCell);
      solutionPath = uniformCostSolver.solutionPath;
      expandedCells = uniformCostSolver.expandedCells;
    } else {
      // Create an AStarSolver instance and find the solution
      AStarSolver aStarSolver = AStarSolver(widget.maze,widget.startCell,widget.goalCell);
      solutionPath = aStarSolver.solutionPath;
      expandedCells = aStarSolver.expandedCells;
    }

    // Check if a solution was found
    if (solutionPath.isNotEmpty) {
      solutionFound = true;
      // Calculate the cost
      solutionCost = calculateSolutionCost(solutionPath);
    } else {
      solutionFound = false;
    }

    setState(() {
      solveButtonClicked = true;
    });
  }

  void showOneByOneNext() {
    setState(() {
      if (partOfExpandedCells.isEmpty) {
        partOfExpandedCells.add(expandedCells.first);
      } else if (partOfExpandedCells.length != expandedCells.length) {
        int i = partOfExpandedCells.length + 1;
        partOfExpandedCells = expandedCells.sublist(0, i);
      }
      if (partOfExpandedCells.length == expandedCells.length) {
        showSolution = true;
      }
    });
  }

  void showOneByOnePrevious() {
    //gerekli mi ki
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (solutionFound)
            FloatingActionButton(
              onPressed: showOneByOneNext,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.arrow_forward),
            ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: solveMaze,
            backgroundColor: Colors.green,
            child: const Icon(Icons.play_arrow),
          ),
        ],
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
                    startCell: widget.startCell,
                    goalCell: widget.goalCell,
                    expandedCells: [],
                    solutionPath: [],
                    controller: _controller,
                    maze: widget.maze,
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
                          startCell: widget.startCell,
                          goalCell: widget.goalCell,
                          expandedCells: partOfExpandedCells,
                          controller: _controller,
                          maze: widget.maze,
                          blockSize: 75,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          solutionPath: showSolution ? solutionPath : [],
                        ),
                      ),
                    ),
                  ),
                  if (showSolution)
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: Text("Solution Cost: $solutionCost",
                          style: const TextStyle(color: Colors.white)),
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
