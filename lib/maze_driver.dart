import 'dart:core';
import 'package:se420/maze_drawer.dart';
import 'package:flutter/material.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class MazeDriverCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [];

  List<Cell> solutionPath;

  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  double rate = 1.0;
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  Function? update;
  Paint _paint = Paint();
  int blockSize = 8;
  BoxConstraints sceneSize = const BoxConstraints(
      minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;

  bool maxRightReached = false;
  List<List<Cell>> maze = [];
  MazeDrawer? mazeMap;
  //

  List<Cell> expandedCells;

  /// Constructor
  MazeDriverCanvas({
    required this.expandedCells,

    required this.solutionPath,

    /// <-- The animation controller
    required this.controller,

    /// <-- The delay until the animation starts
    required this.width,
    required this.height,
    required this.blockSize,
    required this.maze,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    timeDecay = (1 / fps * 1000).round();
    _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.yellow
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    /// make maze
    mazeMap = MazeDrawer(maze: maze, blockSize: blockSize);
  }

  /*
  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    paintImage(canvas, size);

    mazeMap!.update(canvas);
  }
   */

  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    paintImage(canvas, size); // Assuming you have a method to paint the maze background

    mazeMap!.update(canvas);  // Update the maze if necessary

    // Define text style for cell names
    final textStyle = TextStyle(color: Colors.white, fontSize: 14);

    // Loop over each cell to draw its name
    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[0].length; x++) {
        // Get the cell name based on its coordinates
        String cellName = getCellName(x, y);

        // Create a text span with the cell name
        final textSpan = TextSpan(text: cellName, style: textStyle);

        // Create a text painter
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        // Layout the text
        textPainter.layout();

        // Calculate the position to paint the cell name
        Offset position = getPositionForCellName(x, y, blockSize.toDouble()); // Replace cellSize with actual cell size

        // Paint the cell name at the calculated position
        textPainter.paint(canvas, position);
      }
    }
  }


  String getCellName(int x, int y) {
    // Cell names mapping for a 3x3 grid
    Map<String, String> cellNames = {
      '0,0': 'A', '0,1': 'B', '0,2': 'C',
      '1,0': 'D', '1,1': 'E', '1,2': 'F',
      '2,0': 'G', '2,1': 'H', '2,2': 'I',
    };
    return cellNames['$y,$x'] ?? ''; // Return an empty string if the cell is not found
  }

  Offset getPositionForCellName(int x, int y, double cellSize) {
    // Assuming the cellSize is the length of each cell's side
    // Adjust these values if necessary to center the text in each cell
    double offsetX = (x * cellSize) + (cellSize / 2); // Center of the cell horizontally
    double offsetY = (y * cellSize) + (cellSize / 2); // Center of the cell vertically
    return Offset(offsetX, offsetY);
  }


  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    // Draw the maze
    mazeMap!.update(canvas);

    // Set up the paint for filling expanded cells
    _paint.color = Colors.blue; // Color for expanded cells
    _paint.style = PaintingStyle.fill; // Set the paint style to fill

    // Draw expanded cells
    for (Cell cell in expandedCells) {
      // Calculate the rectangle bounds
      Rect cellRect = Rect.fromLTWH(
          cell.x * blockSize,
          cell.y * blockSize,
          blockSize.toDouble(),
          blockSize.toDouble()
      );

      // Draw the filled rectangle for the expanded cell
      canvas.drawRect(cellRect, _paint);
    }

    // Draw the solution path on top of the maze
    if (solutionPath.isNotEmpty) {
      _paint.color = Colors.red;
      _paint.strokeWidth = 4.0;
      for (int i = 0; i < solutionPath.length - 1; i++) {
        Cell current = solutionPath[i];
        Cell next = solutionPath[i + 1];
        canvas.drawLine(
          Offset(current.x * blockSize, current.y * blockSize),
          Offset(next.x * blockSize, next.y * blockSize),
          _paint,
        );
      }
    }
  }
}
