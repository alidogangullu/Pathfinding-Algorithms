import 'package:se420/app/solution_page.dart';
import 'package:se420/maze_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maze_builder/maze_builder.dart';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';

class MazeEdit extends StatefulWidget {
  const MazeEdit({super.key, required this.title});
  final String title;

  @override
  State<MazeEdit> createState() => _MazeEditState();
}

class _MazeEditState extends State<MazeEdit> with TickerProviderStateMixin {
  List<List<Cell>> maze = [];
  late AnimationController _controller;
  List<Map<String, dynamic>> userWalls = [];
  String selectedCell = '0,0'; // Default selected cell
  String selectedDirection = 'top'; // Default selected wall direction

  @override
  Widget build(BuildContext context) {
    Map<String, String> cellNames = {
      '0,0': 'A', '0,1': 'B', '0,2': 'C',
      '1,0': 'D', '1,1': 'E', '1,2': 'F',
      '2,0': 'G', '2,1': 'H', '2,2': 'I',
    };

    List<DropdownMenuItem<String>> cellItems = cellNames.entries
        .map((entry) => DropdownMenuItem(value: entry.key, child: Text('Cell ${entry.value}')))
        .toList();
    // Dropdown menu items for directions
    List<DropdownMenuItem<String>> directionItems = [
      const DropdownMenuItem(value: 'top', child: Text('Top')),
      const DropdownMenuItem(value: 'bottom', child: Text('Bottom')),
      const DropdownMenuItem(value: 'left', child: Text('Left')),
      const DropdownMenuItem(value: 'right', child: Text('Right')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.lightGreen, //background color of dropdown button
                    border: Border.all(
                        color: Colors.black38,
                        width: 2), //border of dropdown button
                    borderRadius: BorderRadius.circular(
                        50), //border raiuds of dropdown button
                    boxShadow: const <BoxShadow>[
                      //apply shadow on Dropdown button
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                          blurRadius: 5) //blur radius of shadow
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: DropdownButton<String>(
                    value: selectedCell,
                    items: cellItems,
                    onChanged: (value) {
                      setState(() {
                        selectedCell = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width:10),
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.lightGreen, //background color of dropdown button
                    border: Border.all(
                        color: Colors.black38,
                        width: 3), //border of dropdown button
                    borderRadius: BorderRadius.circular(
                        50), //border raiuds of dropdown button
                    boxShadow: const <BoxShadow>[
                      //apply shadow on Dropdown button
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                          blurRadius: 5) //blur radius of shadow
                    ]),
                child: DropdownButton<String>(
                  alignment: AlignmentDirectional.centerEnd,
                  value: selectedDirection,
                  items: directionItems,
                  onChanged: (value) {
                    setState(() {
                      selectedDirection = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width:20),
              ElevatedButton(
                onPressed: () => addWall(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Change the box color
                ),
                child: const Text(
                  'Add wall', // Change the text
                  style: TextStyle(
                    color: Colors.white, // Change the text color
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8,),
          ElevatedButton(
            onPressed: () {
              // Navigate to ScreenB when the button is pressed.
              Navigator.push(context, MaterialPageRoute(builder: (context) => SolutionScreen(title: "Solution", maze: maze)));
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Change the box color
            ),
            child: const Text(
              'Solve', // Change the text
              style: TextStyle(
                  color: Colors.white, fontSize: 20 // Change the text color
              ),
            ),
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
          ],
        ),
      ),
    );
  }

  void addWall() {
    // Parse the selected cell coordinates from the dropdown
    var cellCoordinates = selectedCell.split(',');
    int x = int.parse(cellCoordinates[1]);
    int y = int.parse(cellCoordinates[0]);

    // Create a key for the selected wall direction
    String wallKey;
    switch (selectedDirection) {
      case 'top':
        wallKey = 'top';
        break;
      case 'bottom':
        wallKey = 'bottom';
        break;
      case 'left':
        wallKey = 'left';
        break;
      case 'right':
        wallKey = 'right';
        break;
      default:
        wallKey = 'top'; // Default case, though this should never happen
    }

    // Check if there's already an entry for the selected cell in userWalls
    Map<String, dynamic>? existingEntry = userWalls.firstWhereOrNull(
            (wall) => wall['x'] == x && wall['y'] == y);

    if (existingEntry != null) {
      // Update the existing entry with the new wall
      existingEntry[wallKey] = true;
    } else {
      // Add the new wall configuration to userWalls
      userWalls.add({'x': x, 'y': y, wallKey: true});
    }

    // Regenerate the maze with the new wall configuration
    generateMazeBasedOnUserInput();
  }

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

  void generateMazeBasedOnUserInput() {
    int width = 3; // Replace with user input if needed
    int height = 3; // Replace with user input if needed

    // Example user input for walls. Replace with actual user input.
    // Each map entry contains the cell coordinates (x, y) and the walls to modify.
    // 'true' means the wall is present, 'false' means the wall is removed.
    /*List<Map<String, dynamic>> userWalls = [
      {'x': 0, 'y': 0, 'right': true}, // Example
      {'x': 0, 'y': 1, 'top': true},
      // Add more entries based on user input
    ];*/

    List<List<Cell>> localMaze = generate(width: width, height: height);

    // Process each wall addition with respect to neighboring cells
    for (var wallInfo in userWalls) {
      int x = wallInfo['x'];
      int y = wallInfo['y'];
      Cell cell = localMaze[y][x];

      // Update walls of the current cell and its neighbors
      if (wallInfo.containsKey('top')) {
        cell.top = wallInfo['top'];
        if (y > 0) localMaze[y - 1][x].bottom = wallInfo['top'];
      }
      if (wallInfo.containsKey('bottom')) {
        cell.bottom = wallInfo['bottom'];
        if (y < height - 1) localMaze[y + 1][x].top = wallInfo['bottom'];
      }
      if (wallInfo.containsKey('left')) {
        cell.left = wallInfo['left'];
        if (x > 0) localMaze[y][x - 1].right = wallInfo['left'];
      }
      if (wallInfo.containsKey('right')) {
        cell.right = wallInfo['right'];
        if (x < width - 1) localMaze[y][x + 1].left = wallInfo['right'];
      }
    }

    setState(() {
      maze = localMaze;
    });
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
}
