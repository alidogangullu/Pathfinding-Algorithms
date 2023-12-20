import 'package:maze_builder/maze_builder.dart';
import 'package:collection/collection.dart';

class AStarSolver {
  List<List<Cell>> maze;
  List<Cell> solutionPath = [];
  List<Cell> expandedCells = [];

  // Define start and goal cells
  Cell startCell;
  Cell goalCell;

  AStarSolver(this.maze, this.startCell, this.goalCell) {
    solutionPath = findPath();
  }

  List<Cell> findPath() {
    // A* algorithm implementation

    // Define a priority queue for open set
    var openSet = PriorityQueue<AStarNode>();
    openSet.add(AStarNode(
        cell: startCell,
        cost: 0,
        heuristic: manhattanDistance(startCell, goalCell)));

    // Define a map for tracking costs to reach each cell
    Map<Cell, double> costSoFar = {startCell: 0};

    // Define a map for tracking paths
    Map<Cell, Cell?> cameFrom = {startCell: null};

    while (openSet.isNotEmpty && expandedCells.length < 10) {
      var current = openSet.removeFirst().cell;
      expandedCells.add(current);

      // Goal check
      if (current == goalCell) break;

      // Explore neighbors
      for (var next in getNeighbors(current)) {
        double newCost = costSoFar[current]! + cellCost(current, next);

        if (!costSoFar.containsKey(next)) {
          costSoFar[next] = newCost;
          openSet.add(AStarNode(
              cell: next,
              cost: cellCost(current, next),
              heuristic: manhattanDistance(next, goalCell)));
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
        x: current.x + cellSize / 2,
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
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  int cellCost(Cell a, Cell b) {
    // Check if the move is horizontal (right or left)
    if (a.y == b.y) {
      return 2; // Cost for moving right or left
    }
    // Check if the move is vertical (up or down)
    if (a.x == b.x) {
      return 1; // Cost for moving up or down
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

  int calculateSolutionCost(List<Cell> path) {
    // Implement the logic to calculate the cost of the path
    // For example, summing the costs of each move
    int cost = 0;
    for (int i = 0; i < path.length - 1; i++) {
      cost += cellCost(path[i], path[i + 1]);
    }
    return cost;
  }
}

class AStarNode implements Comparable<AStarNode> {
  final Cell cell;
  final int cost;
  final double heuristic;

  AStarNode({required this.cell, required this.cost, required this.heuristic});

  @override
  int compareTo(AStarNode other) {
    return (cost + heuristic).compareTo(other.cost + other.heuristic);
  }
}

class UniformCostSolver {
  List<List<Cell>> maze;
  List<Cell> solutionPath = [];
  List<Cell> expandedCells = [];

  // Define start and goal cells
  Cell startCell;
  Cell goalCell;

  UniformCostSolver(this.maze, this.startCell, this.goalCell) {
    solutionPath = findPath();
  }

  List<Cell> findPath() {
    // Uniform Cost Search implementation

    // Define a priority queue for the open set
    var openSet = PriorityQueue<UniformNode>();
    openSet.add(UniformNode(cell: startCell, cost: 0));

    // Define a map for tracking costs to reach each cell
    Map<Cell, double> costSoFar = {startCell: 0};

    // Define a map for tracking paths
    Map<Cell, Cell?> cameFrom = {startCell: null};

    while (openSet.isNotEmpty && expandedCells.length < 10) {
      var current = openSet.removeFirst().cell;
      expandedCells.add(current);

      // Goal check
      if (current == goalCell) break;

      // Explore neighbors
      for (var next in getNeighbors(current)) {
        double newCost = costSoFar[current]! + cellCost(current, next);

        if (!costSoFar.containsKey(next) || newCost < costSoFar[next]!) {
          costSoFar[next] = newCost;
          openSet.add(UniformNode(cell: next, cost: newCost));
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

    while (current != start && current != null) {
      path.add(current);
      current = cameFrom[current];
    }

    if (current == null) {
      // No valid path to the start cell was found
      return [];
    }

    path.add(start);
    return path.reversed.toList();
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

int calculateSolutionCost(List<Cell> path) {
  // Implement the logic to calculate the cost of the path
  // For example, summing the costs of each move
  int cost = 0;
  for (int i = 0; i < path.length - 1; i++) {
    cost += cellCost(path[i], path[i + 1]);
  }
  return cost;
}

int cellCost(Cell a, Cell b) {
  // Check if the move is horizontal (right or left)
  if (a.y == b.y) {
    return 2; // Cost for moving right or left
  }
  // Check if the move is vertical (up or down)
  if (a.x == b.x) {
    return 1; // Cost for moving up or down
  }
  // This condition should never happen in a 4-directional grid
  throw Exception("Invalid move detected");
}

class UniformNode implements Comparable<UniformNode> {
  final Cell cell;
  final double cost;

  UniformNode({required this.cell, required this.cost});

  @override
  int compareTo(UniformNode other) {
    return cost.compareTo(other.cost);
  }
}
