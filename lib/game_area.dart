import 'dart:math';

import 'package:tetris/combinations.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game_colors.dart';

class ScoreToInterval {
  final int score;
  final int interval;
  ScoreToInterval(this.score, this.interval);
}

List<ScoreToInterval> intervals = [
  ScoreToInterval(0, 1000), // Initial speed
  ScoreToInterval(100000, 800),
  ScoreToInterval(200000, 600),
  ScoreToInterval(300000, 500),
  ScoreToInterval(400000, 400),
  ScoreToInterval(500000, 350),
  ScoreToInterval(600000, 300),
  ScoreToInterval(700000, 275),
  ScoreToInterval(800000, 250),
  ScoreToInterval(900000, 225),
  ScoreToInterval(910000, 200),
  ScoreToInterval(920000, 180),
  ScoreToInterval(930000, 160),
  ScoreToInterval(940000, 150),
  ScoreToInterval(950000, 140),
  ScoreToInterval(960000, 130),
  ScoreToInterval(970000, 120),
  ScoreToInterval(980000, 110),
  ScoreToInterval(990000, 100),
]; // Default speed

class Playground {
  final List<List<int>> _grid = List.generate(10, (_) => List.filled(22, 0));
  int getGridValue(int x, int y) {
    if (x < 0 || x >= 10 || y < 0 || y >= 22) return 1;
    return _grid[x][y];
  }

  void setGridValue(int x, int y, int value) {
    if (x < 0 || x >= 10 || y < 0 || y >= 22) return;
    _grid[x][y] = value;
  }
}

class GameArea {
  Playground playground = Playground();

  Combination? fallingCombination;
  Point<int> position = Point(3, 0);

  PreviewArea previewArea;

  int score = 0;
  bool isPaused = false;
  bool isGameOver = false;
  int duration = 0;
  bool needRepaint = true;

  GameArea(this.previewArea) {
    fallingCombination = getNextCombination();
  }

  void rotate() {
    if (isGameOver || isPaused) return;
    needRepaint = true;
    fallingCombination!.rotate();
    if (isCollision()) {
      fallingCombination!.rotate(-1);
    }
  }

  void moveLeft() {
    if (isGameOver || isPaused) return;
    needRepaint = true;
    position = Point(position.x - 1, position.y);
    if (isCollision()) {
      position = Point(position.x + 1, position.y);
    }
  }

  void moveRight() {
    if (isGameOver || isPaused) return;
    needRepaint = true;
    position = Point(position.x + 1, position.y);
    if (isCollision()) {
      position = Point(position.x - 1, position.y);
    }
  }

  void moveDown() {
    if (isGameOver || isPaused) return;
    needRepaint = true;
    _fall();
  }

  void _fall() {
    position = Point(position.x, position.y + 1);
    if (isCollision()) {
      position = Point(position.x, position.y - 1);
      mergeCombination();
      score += calculateScore(clearRow());
      fallingCombination = getNextCombination();
      position = Point(3, 0);
      if (isCollision()) {
        isGameOver = true; // Game over logic can be added here
      }
    }
  }

  void onTimer(int milliseconds) {
    duration += milliseconds;

    for (var i = intervals.length - 1; i >= 0; i--) {
      if (score >= intervals[i].score) {
        if (duration >= intervals[i].interval) {
          moveDown();
          duration = 0;
        }
        break; // Found the appropriate interval, no need to check further
      }
    }
  }

  void reset() {
    playground = Playground();
    score = 0;
    isGameOver = false;
    position = Point(3, 0);
    fallingCombination = getNextCombination();
  }
  

  void pause() {
    isPaused = !isPaused;
  }

  bool isCollision() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (playground.getGridValue(position.x + j, position.y + i) +
                fallingCombination!.currentShape[i][j] >
            1) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeCombination() {
    if (fallingCombination == null) return;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (fallingCombination!.currentShape[i][j] != 0) {
          playground.setGridValue(
            position.x + j,
            position.y + i,
            fallingCombination!.currentShape[i][j],
          );
        }
      }
    }
  }

  int clearRow() {
    int clearedRows = 0;
    for (int i = 0; i < 22; i++) {
      bool isFull = true;
      for (int j = 0; j < 10; j++) {
        if (playground.getGridValue(j, i) == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        clearedRows++;
        for (int k = i; k > 0; k--) {
          for (int j = 0; j < 10; j++) {
            playground.setGridValue(j, k, playground.getGridValue(j, k - 1));
          }
        }
      }
    }
    return clearedRows;
  }

  int calculateScore(int clearedRows) {
    return pow(2, clearedRows).toInt() * 100 - 100;
  }

  Combination getNextCombination() {
    Combination combination = previewArea.currentCombination;
    previewArea.makeNewPreview();
    return combination;
  }

  void paint(Canvas canvas, Size size, Size brickSize) {
    final paintBG = Paint()
      ..color = GameColors.gameAreaGrid
      ..style = PaintingStyle.fill;
    final paintFG = Paint()
      ..color = GameColors.gameAreaSquare
      ..style = PaintingStyle.fill;

    // 画一个 100x100 的正方形
    for (int i = 0; i < 22; i++) {
      for (int j = 0; j < 10; j++) {
        int fallingY = i - position.y;
        int fallingX = j - position.x;
        canvas.drawRect(
          Rect.fromLTWH(
            j * brickSize.width,
            i * brickSize.height,
            brickSize.width - 1,
            brickSize.height - 1,
          ),
          (playground.getGridValue(j, i) == 1 ||
                  (fallingX < 4 &&
                      fallingY < 4 &&
                      fallingX >= 0 &&
                      fallingY >= 0 &&
                      fallingCombination!.currentShape[fallingY][fallingX] ==
                          1))
              ? paintFG
              : paintBG,
        );
      }
    }
    if (isGameOver) {
      paintGameOver(canvas, size);
    }
  }

  List<Color> colors = [GameColors.gameOverText1, GameColors.gameOverText2];
  double colorIndex = 0;
  void paintGameOver(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: 'GAME OVER \n',
          style: TextStyle(
            color: colors[((colorIndex += 0.05).toInt() % colors.length)],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: 'Press Restart to play again\n',
          style: TextStyle(
            color: colors[(colorIndex.toInt() % colors.length)],
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr, // 必须指定，否则不会渲染
      textAlign: TextAlign.center,
    );

    // 先布局
    textPainter.layout(minWidth: size.width, maxWidth: size.width);

    // 指定绘制位置
    final offset = Offset(0, 100);

    // 绘制到 Canvas
    textPainter.paint(canvas, offset);
  }
}

class PreviewArea {
  Combination _combination = CombinationFactory().createCombination();
  void makeNewPreview() {
    _combination = CombinationFactory().createCombination();
  }

  Combination get currentCombination => _combination;
  void paint(Canvas canvas, Size size, Size brickSize) {
    final paintFG = Paint()
      ..color = GameColors.gameAreaSquare
      ..style = PaintingStyle.fill;
      final paintBG = Paint()
      ..color = GameColors.gameAreaGrid
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawRect(
          Rect.fromLTWH(
            (j + 10) * brickSize.width + 15,
            i * brickSize.height,
            brickSize.width - 1,
            brickSize.height - 1,
          ),
          _combination.currentShape[i][j] == 0 ? paintBG : paintFG,
        );
      }
    }
  }
}
