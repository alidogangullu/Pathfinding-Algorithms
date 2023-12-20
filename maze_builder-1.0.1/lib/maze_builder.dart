class Cell {
  double x;
  double y;
  bool top;
  bool left;
  bool right;
  bool bottom;
  double? set;

  /// The cell model class
  Cell({
    required this.x,
    required this.y,
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
    this.set,
  });

  getPropertyByKey(String key) {
    switch (key) {
      case "set":
        {
          return set;
        }

      case "x":
        {
          return x;
        }

      case "y":
        {
          return y;
        }

      case "top":
        {
          return top;
        }
      case "bottom":
        {
          return bottom;
        }
      case "left":
        {
          return left;
        }
      case "right":
        {
          return right;
        }
    }
  }
}

/// [internal function] make a list based on a predicate
List<dynamic> compact(List<dynamic> array) {
  return array.where((u) => u != 0.0).toList();
}

/// [internal function] difference between two lists
List<dynamic> difference(List<dynamic> c, List<dynamic> d) {
  return [c, d].reduce((a, b) => c.toSet().difference(b.toSet()).toList());
}

List<dynamic> initial(List<dynamic> array) {
  return array.sublist(0, array.length - 1);
}

/// { [key]: T[] }
Map<int, List<dynamic>> oldgroupBy(List<Cell> list, String key) {
  List<dynamic> keys = list.map((item) => item.getPropertyByKey(key)).toList();
  var uniqKeys = uniq(keys).toList();
  Map<int, List<dynamic>> _dict = {};
  uniqKeys.asMap().forEach((index, element) {
    _dict[element.toInt()] = [];
  });

  // uniqKeys.reduce((prev, next) => {
  //       {
  //         ...prev,
  //         [next]: []
  //       }
  //     });
  Map<int, List<dynamic>> dict = _dict;

  list.forEach((item) => dict[item.getPropertyByKey(key)]?.add(item));
  //print(dict);
  return dict;
}

/// [internal function] group iterables by predicate
Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
  var map = <T, List<S>>{};
  for (var element in values) {
    (map[key(element)] ??= []).add(element);
  }
  return map;
}

/// [internal function] get the last element of a list
last(List<dynamic> array) {
  return array[array.length - 1];
}

/// [internal function] make a list based on predicate
Iterable range(double n, {int end = 0}) {
  return end != 0
      ? List.from(List.generate(end - n.round(), (int index) => index,
              growable: true))
          .map((k) => k + n)
      : List.from(
          List.generate(n.round(), (int index) => index, growable: true));
}

/// [internal function] return a duplicate free list
List<dynamic> uniq(List<dynamic> array) {
  return [...new Set.from(array)];
}

/// [internal function] return a list with random elements
List<dynamic> sampleSize(List<dynamic>? array, double? n, Function random) {
  n = n ?? 1;
  double length = (array == null) ? 0.0 : array.length.toDouble();

  /// !length note
  if (length == 0 || n < 1) {
    return [];
  }
  n = n > length ? length : n;
  int index = -1;
  double lastIndex = length - 1;
  List result = [...?array];
  while (++index < n) {
    //var _random = random();
    var rand = index + (random() * (lastIndex - index + 1)).floor() as int;
    Cell value = result[rand];
    result[rand] = result[index];
    result[index] = value;
  }
  return result.sublist(0, n.round());
}

/// [internal function] randomization engine
Function mulberry32(int seed) {
  return () {
    seed += 0x6D2B79F5;
    int t = seed;
    t = imul2(t ^ t >> 15, t | 1);
    t ^= t + imul2(t ^ t >> 7, t | 61);
    double result = ((t ^ t >> 14) >> 0) / 4294967296;

    return result;
  };
}

/// [internal function] imul2 implementation in Dart
int imul2(int a, int b) {
  int aHi = (a >> 16) & 0xffff;
  int aLo = a & 0xffff;
  int bHi = (b >> 16) & 0xffff;
  int bLo = b & 0xffff;
  // the shift by 0 fixes the sign on the high part
  // the final |0 converts the unsigned value into a signed value
  return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) << 16) >> 0)).toSigned(32);
}

/// [internal function] merge a list with another
List<Cell> mergeSetWith(List<Cell> row, double oldSet, double newSet) {
  row.forEach((box) {
    if (box.set == oldSet) box.set = newSet;
  });

  return row;
}

/// [internal function] add missing set to list
List<Cell> populateMissingSets(List<Cell> row, Function random) {
  var _map = row.map((row) => row.set).toList();
  List<dynamic> _uniq = uniq(_map);
  List<dynamic> setsInUse = compact(_uniq);
  List<dynamic> allSets = range(1, end: row.length + 1).toList();
  List<dynamic> diff = difference(allSets, setsInUse);
  List<double> availableSets = diff.cast<double>();
  availableSets.sort((a, b) => (0.5 - random()).sign.toInt());
  // print("$availableSets, $setsInUse, $allSets");
  row.where((box) => box.set == 0).toList().asMap().forEach((i, box) {
    box.set = availableSets[i];
  });

  return row;
}

/// [internal function] merge randomized sets into a new list
List<Cell> mergeRandomSetsIn(List<Cell> row, Function random,
    {probability = 0.5}) {
  // Randomly merge some disjoint sets

  var allBoxesButLast = initial(row);
  allBoxesButLast.asMap().forEach((x, current) {
    var next = row[x + 1];
    var differentSets = current.set != next.set;
    var rand = random();
    var shouldMerge = rand <= probability;

    if (current.x == 0 && current.y == 0) {
      //print(">>>> $rand  $differentSets $shouldMerge ${current.set}, ${next.set}");
    }
    if (differentSets && shouldMerge) {
      row = mergeSetWith(row, next.set!, current.set);
      current.right = false;
      row[x + 1].left = false;
    }
  });

  allBoxesButLast.add(row[row.length - 1]);
  return allBoxesButLast as List<Cell>;
}

/// [internal function] randomly add an exit to each set
addSetExits(List<Cell> row, List<Cell> nextRow, Function random) {
  // Randomly add bottom exit for each set
  List<dynamic> setsInRow = [];

  groupBy(row, (item) => (item).set!.round()).forEach((key, value) {
    setsInRow.add(value);
  });

  setsInRow.forEach((set) {
    List<dynamic> exits =
        sampleSize(set, (random() * set.length).ceil().toDouble(), random);
    exits.forEach((exit) {
      //if (exit) {
      Cell below = nextRow[exit.x.round()];
      exit.bottom = false;
      below.top = false;
      below.set = exit.set;
      //}
    });
  });

  return setsInRow;
}

/// Generate a maze (List of List of Cell objects)
List<List<Cell>> generate(
    {int width = 8, int height = 0}) {
  height = width;

  List<List<Cell>> maze = [];

  // Populate maze with cells, setting specific walls for edge cells.
  for (var y = 0; y < height; y++) {
    var row = List.generate(width, (x) {
      // Default walls set to false
      bool topWall = false, leftWall = false, bottomWall = false, rightWall = false;

      // Setting specific walls for border cells
      if (y == 0) topWall = true;         // Top edge
      if (x == 0) leftWall = true;        // Left edge
      if (y == height - 1) bottomWall = true; // Bottom edge
      if (x == width - 1) rightWall = true;   // Right edge

      return Cell(
        x: x.toDouble(),
        y: y.toDouble(),
        top: topWall,
        left: leftWall,
        bottom: bottomWall,
        right: rightWall,
        set: 0,
      );
    });
    maze.add(row);
  }

  /*
  var r = range(width.toDouble());

  // Populate maze with empty cells:
  for (var y = 0; y < height; y += 1) {
    var row = r.map((x) {
      return Cell(
        x: x.toDouble(),
        y: y.toDouble(),
        top: true,
        left: true,
        bottom: true,
        right: true,
        set: 0,
      );
    }).toList();
    maze.add(row);
  }

  // Remove inner walls
  maze.forEach((row) {
    row.forEach((cell) {
      //bos maze icin hepsi false olmali

      if(cell.x == 0 && cell.y == 0){
        cell.bottom=false; //AD
        cell.right=false; //AB
      }
      if(cell.x == 0 && cell.y == 1){
        cell.top = false; //AD
        //cell.right = false; //DE
        //cell.bottom = false; //DG
      }
      if(cell.x == 1 && cell.y == 0){
        cell.bottom=false; //BE
        cell.left=false; //AB
        cell.right=false; //BC
      }
      if(cell.x == 1 && cell.y == 1){
        cell.top = false; //BE
        //cell.left=false; //DE
        cell.right=false; //EF
        cell.bottom=false; //EH
      }
      if(cell.x == 2 && cell.y == 0){
        cell.bottom=false; //CF
        cell.left=false; //BC
      }
      if(cell.x == 2 && cell.y == 1){
        cell.top = false; //CF
        cell.bottom = false; //FI
        cell.left = false; //EF
      }
      if(cell.x == 0 && cell.y == 2){
        //cell.top = false; //DG
        cell.right = false; //GH
      }
      if(cell.x == 1 && cell.y == 2){
        cell.top = false; //EH
        cell.left = false; //GH
        cell.right = false; //HI
      }
      if(cell.x == 2 && cell.y == 2){
        cell.top = false; //FI
        cell.left = false; //HI
      }
    });
  });
   */
  return maze;
}
