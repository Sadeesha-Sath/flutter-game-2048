import 'package:flutter/material.dart';
import 'package:flutter_game_2048/src/models/tile.dart';
import 'package:flutter_game_2048/src/logic/methods.dart';
import 'package:flutter_game_2048/src/ui/screens/custom_bottom_sheet.dart';

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
    controllerAddStatusListener();
    initializeGame(grid, flattenedGrid);
  }

  void controllerAddStatusListener() {
    return controller.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          toAdd.forEach((element) {
            grid[element.y][element.x].val = element.val;
          });
          flattenedGrid.forEach((element) {
            element.resetAnimations();
          });
          if (flattenedGrid.any((element) => element.val == 2048)) {
            // Player Wins
            showCustomBottomSheet(
              context,
              () {
                setState(() {
                  resetGame();
                  Navigator.pop(context);
                });
              },
              title: "You Win!",
              buttonText: "Up for another challenge?",
            );
          }
          if (!flattenedGrid.any((element) => element.val == 0)) {
            bool gameOver = isGameOver(grid, columns);
            if (gameOver) {
              showCustomBottomSheet(context, () {
                setState(() {
                  resetGame();
                  Navigator.pop(context);
                });
              });
            }
          }
        }
      },
    );
  }

  void resetGame() {
    grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
    initializeGame(grid, flattenedGrid);
  }

  void addNewTile() {
    toAdd = [];
    List<Tile> empty = flattenedGrid.where((element) => element.val == 0).toList();
    empty.shuffle();
    toAdd.add(Tile(empty.first.x, empty.first.y, 2)..appear(controller));
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 15 * 2;
    double tileSize = (gridSize - 4 * 2) / 4;
    List<Widget> stackItem = [];
    buildAddAll(stackItem: stackItem, tileSize: tileSize, flattenedGrid: flattenedGrid);
    buildAddAllListContent(
        stackItem: stackItem, tileSize: tileSize, controller: controller, flattenedGrid: flattenedGrid, toAdd: toAdd);
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text("2048"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                resetGame();
              });
            },
            icon: Icon(
              Icons.settings_backup_restore_outlined,
            ),
          ),
        ],
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
