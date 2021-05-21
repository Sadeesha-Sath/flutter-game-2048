import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_game_2048/src/models/tile.dart';
import 'package:flutter_game_2048/src/ui/ui_constants.dart';

bool isGameOver(List<List<Tile>> grid, Iterable<List<Tile>> columns) {
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

void initializeGame(List<List<Tile>> grid, Iterable<Tile> flattenedGrid) {
  var random = Random();
  Set<List<int>> indexes = {
    [0, 0],
    [0, 1],
    [0, 2],
    [0, 3],
    [1, 0],
    [1, 1],
    [1, 2],
    [1, 3],
    [2, 0],
    [2, 1],
    [2, 2],
    [2, 3],
    [3, 0],
    [3, 1],
    [3, 2],
    [3, 3]
  };
  List<int> values = [2, 2, 4, 4, 8, 16, 32, 64];
  for (int i = 0; i < 8; ++i) {
    List<int> newIndex = indexes.elementAt(random.nextInt(indexes.length));
    grid[newIndex[0]][newIndex[1]].val = values[random.nextInt(values.length)];
    indexes.remove(newIndex);
  }
  flattenedGrid.forEach((element) {
    element.resetAnimations();
  });
}

void buildAddAll({required List<Widget> stackItem, required double tileSize,required Iterable<Tile> flattenedGrid}) {
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
  }

  void buildAddAllListContent({required List<Widget> stackItem, required double tileSize, required Iterable<Tile> flattenedGrid,required List<Tile>  toAdd, required AnimationController controller}) {
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
  }

  