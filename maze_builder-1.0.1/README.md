<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Maze builder using a Dart implementation of Eller's Algorithm, as described here: http://www.neocomputer.org/projects/eller.html

This algorithm creates 'perfect' mazes, which guarantees a single path between any two cells, such as:
```
+---+---+---+---+---+---+---+
|           |           |   |
+---+   +---+   +   +   +   +
|   |   |       |   |       |
+   +   +   +   +   +   +   +
|       |   |   |   |   |   |
+   +---+   +   +---+---+   +
|   |   |   |   |   |   |   |
+   +   +   +   +   +   +   +
|   |       |   |   |       |
+   +---+   +---+   +---+---+
|   |   |   |       |       |
+   +   +   +   +---+   +   +
|                       |   |
+---+---+---+---+---+---+---+
```

This library generates a two-dimensional array of maze cells, each with the following properties:

    {
      x: 4,          // Horizontal position, integer
      y: 7,          // Vertical position, integer
      top: false,    // Top/Up has a wall/blocked if true, boolean 
      left: false,   // Left has a wall/blocked if true, boolean
      bottom: true,  // Bottom/Down has a wall/blocked if true, boolean
      right: true,   // Right has a wall/blocked if true, boolean
      set: 5         // Set # used to generate maze, can be ignored
    }

## Features

The example of this package also draws the lines using Flutter CustomPainter.

## Getting started

add the library `import 'package:maze_builder/maze_builder.dart';`

## Usage


```dart
Random rand = Random();
List<List<Cell>> localMaze = generate(width: 200, height: 200, closed: true, seed: rand.nextInt(100000));
```

Receive a `Cell` array of all the points of the map

Then draw them

```dart
makeBlocks() {
    int mazeLength = maze.length;
    for (var i = 0; i < mazeLength; i++) {
      for (var j = 0; j < maze[i].length; j++) {
        getBlockLines(maze[i][j], i);
      }
    }
  }

  getBlockLines(Cell cell, int index) {
    
    int size = 24;
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

    // DRAW LINE ///////////////////////////////
  void drawLine(double x, double y, double targetX, double targetY, Paint paint) {

    canvas!.drawLine(
        Offset(x, y),
        Offset(targetX, targetY),
        paint,
    );

   }

  ```


## Additional information

This library is a direct Dart port of https://github.com/bestguy/generate-maze
