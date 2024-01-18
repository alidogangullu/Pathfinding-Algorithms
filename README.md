# SE 420 Course Artificial Intelligence and Expert Systems Project

  In this project, we have implemented a 3x3 rooms pathfinding game using Flutter and maze_builder Flutter package. At the beginning in the game, user must enter start and goal cells, walls between cells and search algorithm (A* Search or Uniform Cost Search). According to these inputs, the aim of the game is to reach the goal with an algorithm with the least cost. There are some restrictions and modifications in calculation of costs and reaching to goal.

## Game Explanation

  In the game, the robot can be moved only up, down, left, or right. Movements have different costs; up or down move -> cost =1, right or left move -> cost =2.
After the user chooses the initial state, goal state and walls between rooms; user must choose a search algorithm for searching the solution. The expansion will go to the 10th expanded node. If a solution can’t be found until the 10th expansion, then there is no solution. If a solution can be found, the user can see expansions one by one also, after the solution path is found the user can see solution cost.
There are two algorithms for search: A* and Uniform Cost Search. In the UCS, the cost value of each cell is calculated by only the total cost of movement of tiles. On the other in A*, the cost value of each node is calculated by hamming distance (as a heuristic) + total cost of movement from one cell to another.

## Screenshots

<img src="https://github.com/alidogangullu/se420_2/blob/master/screenshots/screenshot%20-%201.jpeg" alt="Maze Builder" width="250"/>    <img src="https://github.com/alidogangullu/se420_2/blob/master/screenshots/screenshot%20-%202.jpeg?raw=true" alt="A* Solution" width="250"/>    <img src="https://github.com/alidogangullu/se420_2/blob/master/screenshots/screenshot%20-%203.jpeg?raw=true" alt="Uniform Cost Solution" width="250"/>
