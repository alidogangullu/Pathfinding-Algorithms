import 'dart:core';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;

class MazeDrawer {
  Color color = const Color.fromARGB(255, 254, 238, 13);
  Canvas? canvas;
  Paint _paint = Paint();
  double radius = 10.0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  final _random = Random();
  int blockSize = 8;
  List<List<Cell>> maze = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  bool isMazeDrawn = false;
  final Rect _bounds = const Rect.fromLTWH(0, 0, 0, 0);

  bool maxRightReached = false;

  /// Constructor
  MazeDrawer({
    required this.maze,

    /// <-- The delay until the animation starts
    required this.blockSize,
    solution,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,
  }) {
    /// default painter

    _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;
  }

  void update(Canvas canvas) {
    this.canvas = canvas;
    makeBlocks();
  }

  makeBlocks() {
    int mazeLength = maze.length;
    for (var i = 0; i < mazeLength; i++) {
      for (var j = 0; j < maze[i].length; j++) {
        getBlockLines(maze[i][j], i);
      }
    }

    isMazeDrawn = true;
  }

  getBlockLines(Cell cell, int index) {
    //var lines = [];
    //print(cell);
    int size = blockSize;
    if (cell.top) {
      double x1 = cell.x * size;
      double y1 = cell.y * size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size;
      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.bottom) {
      double x1 = cell.x * size;
      double y1 = cell.y * size + size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.left) {
      double x1 = cell.x * size;
      double y1 = cell.y * size;
      double x2 = cell.x * size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.right) {
      double x1 = cell.x * size + size;
      double y1 = cell.y * size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    updateCanvas(0, 0, () {
      canvas!.drawCircle(Offset(x, y), radius, paint);
    });
  }

  // DRAW LINE ///////////////////////////////
  void drawLine(
      double x, double y, double targetX, double targetY, Paint paint) {
    //Rect bounds = _camera!.getCameraBounds();

    updateCanvas(_bounds.left * -1, _bounds.top, () {
      //print("$x, $y, $signX, $signY");
      canvas!.drawLine(
        Offset(x, y),
        Offset(targetX, targetY),
        paint,
      );
    }, translate: true);
  }

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius);

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - printTime > 10) {
      printTime = DateTime.now().millisecondsSinceEpoch;
      //print(str);
    }
  }

  void updateCanvas(double? x, double? y, VoidCallback callback,
      {bool translate = false}) {
    double localX = x ?? 0;
    double localY = y ?? 0;
    canvas!.save();
    if (translate) {
      canvas!.translate(localX, localY);
    }
    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
