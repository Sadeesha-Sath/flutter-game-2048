import 'package:flutter/material.dart';
import 'package:flutter_game_2048/src/models/tile.dart';
import 'package:flutter_game_2048/src/ui/ui_constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  List<List<Tile>> grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
  List<Tile> toAdd = [];
  Iterable<Tile> get flattenedGrid => grid.expand((element) => element);
  Iterable<List<Tile>> get columns => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        toAdd.forEach((element) {
          grid[element.y][element.x].val = element.val;
        });
        flattenedGrid.forEach((element) {
          element.resetAnimations();
        });
        print("Checking");
        if (!flattenedGrid.any((element) => element.val == 0)) {
          bool gameOver = isGameOver();
          print("Is game Over $gameOver");
          if (gameOver) {
            showModalBottomSheet(
                context: context,
                enableDrag: true,
                backgroundColor: Colors.amber.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                builder: (context) => Container());
          }
        }
      }
    });

    // TODO Dynamically add values
    // TODO Add Game Over
    // TODO Add reset Functionality
    // TODO Refractor code
    // TODO Improve the algorithm

    grid[1][2].val = 4;
    grid[3][2].val = 16;
    grid[0][1].val = 2;
    grid[0][0].val = 2;
    grid[3][2].val = 4;
    grid[1][2].val = 16;
    grid[1][1].val = 2;
    grid[3][3].val = 2;
    grid[2][2].val = 4;
    grid[2][1].val = 16;
    grid[2][3].val = 2;
    grid[3][0].val = 2;

    flattenedGrid.forEach((element) {
      element.resetAnimations();
    });
  }

  void addNewTile() {
    toAdd = [];
    List<Tile> empty = flattenedGrid.where((element) => element.val == 0).toList();
    empty.shuffle();
    toAdd.add(Tile(empty.first.x, empty.first.y, 2)..appear(controller));
  }

  bool isGameOver() {
    for (List<Tile> row in grid) {
      for (int i = 0; i < 3; ++i) {
        if (row[i].val == row[i + 1].val) {
          return false;
        }
      }
    }
    for (List<Tile> column in columns) {
      for (int i = 0; i < 3; ++i) {
        if (column[i].val == column[i + 1].val) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 15 * 2;
    double tileSize = (gridSize - 4 * 2) / 4;
    List<Widget> stackItem = [];
    stackItem.addAll(
      flattenedGrid.map(
        (e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4 * 2,
              height: tileSize - 4 * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: kTileBackgroundColor,
              ),
            ),
          ),
        ),
      ),
    );

    stackItem.addAll(
      [flattenedGrid, toAdd].expand((element) => element).map(
            (e) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) => e.animatedValue.value == 0
                  ? SizedBox()
                  : Positioned(
                      left: e.animatedX.value * tileSize,
                      top: e.animatedY.value * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Center(
                        child: Container(
                          width: (tileSize - 4 * 2) * e.scale.value,
                          height: (tileSize - 4 * 2) * e.scale.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kNumTileColors[e.animatedValue.value],
                          ),
                          child: Center(
                            child: Text(
                              "${e.animatedValue.value}",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                color: e.animatedValue.value <= 4 ? Colors.grey.shade700 : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
    );
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text("2048"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings_backup_restore_outlined))],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -100 && canSwipeUp()) {
            // Swipe Up
            doSwipe(swipeUp);
          } else if (details.velocity.pixelsPerSecond.dy > 100 && canSwipeDown()) {
            // Swipe Down
            doSwipe(swipeDown);
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < -700 && canSwipeLeft()) {
            // Swipe Left
            doSwipe(swipeLeft);
          } else if (details.velocity.pixelsPerSecond.dx > 700 && canSwipeRight()) {
            // Swipe right
            doSwipe(swipeRight);
          }
        },
        child: Container(
          child: Center(
            child: Container(
              height: gridSize,
              width: gridSize,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.brown.shade200,
              ),
              child: Stack(
                children: stackItem,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFunc) {
    setState(() {
      swipeFunc();
      // Add New Tile
      addNewTile();
      controller.forward(from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => columns.any(canSwipe);
  bool canSwipeDown() => columns.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((element) => element.val != 0)) {
          return true;
        }
      } else {
        Tile? nextNonZero = tiles.skip(i + 1).firstWhere((element) => element.val != 0, orElse: () => Tile(-1, -1, -1));
        if (nextNonZero.val == -1) nextNonZero = null;
        if (nextNonZero != null && nextNonZero.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
  void swipeUp() => columns.forEach(mergeTiles);
  void swipeDown() => columns.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      Iterable<Tile> toCheck = tiles.skip(i).skipWhile((value) => value.val == 0);
      if (toCheck.isNotEmpty) {
        Tile t = toCheck.first;
        Tile? merge = toCheck.skip(1).firstWhere((element) => element.val != 0, orElse: () => Tile(-1, -1, -1));
        if (merge.val == -1) merge = null;
        if (merge != null && merge.val != t.val) {
          merge = null;
        }
        if (tiles[i] != t || merge != null) {
          int resultValue = t.val;
          t.moveTo(controller, tiles[i].x, tiles[i].y);
          // Animate t position
          if (merge != null) {
            resultValue += merge.val;
            merge.moveTo(controller, tiles[i].x, tiles[i].y);
            merge.bounce(controller);
            merge.changeNumber(controller, resultValue);
            merge.val = 0;
            t.changeNumber(controller, 0);
          }
          t.val = 0;
          tiles[i].val = resultValue;
        }
      }
    }
  }
}
