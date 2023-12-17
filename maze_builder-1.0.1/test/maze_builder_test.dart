import 'package:flutter_test/flutter_test.dart';

import 'package:maze_builder/maze_builder.dart';

void main() {
  test('adds one to input values', () {
    final maze = generate();
    expect(maze.length, maze.isNotEmpty);
  });
}
