import 'dart:math';

import 'package:tetris/combinations.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game_colors.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FrozenNotifier extends ChangeNotifier {
  void toggle() {
    notifyListeners();
  }
}

class ClearNotifier extends ChangeNotifier {
  void toggle() {
    notifyListeners();
  }
}

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

  String toJson() {
    return jsonEncode(_grid);
  }

  void fromJson(String jsonString) {
    List<dynamic> jsonData = jsonDecode(jsonString);
    for (int i = 0; i < 10; i++) {
      _grid[i] = List<int>.from(jsonData[i]);
    }
  }
}

class GameArea {
  Playground playground = Playground();

  Combination? fallingCombination;
  Point<int> fallingPosition = Point(3, 0);

  PreviewArea previewArea;

  int score = 0;
  bool isPaused = false;
  bool isGameOver = false;
  bool isShowAbout = false;
  int duration = 0;
  bool needRepaint = true;
  FrozenNotifier frozenNotifier = FrozenNotifier();
  ClearNotifier clearNotifier = ClearNotifier();

  GameArea(this.previewArea) {
    fallingCombination = previewArea.getCombination();
  }

  void rotate() {
    if (isGameOver || isPaused || isShowAbout) return;
    needRepaint = true;
    fallingCombination!.rotate();
    if (isCollision()) {
      fallingCombination!.rotate(-1);
    }
  }

  void moveLeft() {
    if (isGameOver || isPaused || isShowAbout) return;
    needRepaint = true;
    fallingPosition = Point(fallingPosition.x - 1, fallingPosition.y);
    if (isCollision()) {
      fallingPosition = Point(fallingPosition.x + 1, fallingPosition.y);
    }
  }

  void moveRight() {
    if (isGameOver || isPaused || isShowAbout) return;
    needRepaint = true;
    fallingPosition = Point(fallingPosition.x + 1, fallingPosition.y);
    if (isCollision()) {
      fallingPosition = Point(fallingPosition.x - 1, fallingPosition.y);
    }
  }

  void moveDown() {
    if (isGameOver || isPaused || isShowAbout) return;
    needRepaint = true;
    _fall();
  }

  void _fall() {
    fallingPosition = Point(fallingPosition.x, fallingPosition.y + 1);
    if (isCollision()) {
      fallingPosition = Point(fallingPosition.x, fallingPosition.y - 1);
      mergeCombination();

      int clearedRows = clearRow();
      clearedRows > 0 ? clearNotifier.toggle() : frozenNotifier.toggle();

      score += calculateScore(clearedRows);
      fallingCombination = previewArea.getCombination();
      fallingPosition = Point(3, 0);
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
    fallingPosition = Point(3, 0);
    previewArea.getCombination();
    fallingCombination = previewArea.getCombination();
  }

  void pause() {
    isPaused = !isPaused;
  }
  void showAbout() {
    isShowAbout = !isShowAbout;
  }

  void saveGame() {
    Map<String, dynamic> data = {
      'playground': playground.toJson(),
      'fallingCombination': fallingCombination?.toJson(),
      'previewArea': previewArea._previewCombination.toJson(),
      'position': {'x': fallingPosition.x, 'y': fallingPosition.y},
      'score': score,
      'isPaused': isPaused,
      'isGameOver': isGameOver,
      'duration': duration,
    };
    _writeData(data);
  }

  void loadGame() async {
    Map<String, dynamic> data = await _readData();
    if (data.isEmpty) return;
    playground.fromJson(data['playground']);
    fallingCombination = Combination.fromJson(data['fallingCombination']);
    previewArea._previewCombination = Combination.fromJson(data['previewArea']);
    fallingPosition = Point(data['position']['x'], data['position']['y']);
    score = data['score'];
    isPaused = data['isPaused'];
    isGameOver = data['isGameOver'];
    duration = data['duration'];
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  // 写入数据
  Future<File> _writeData(Map<String, dynamic> data) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(data));
  }

  // 读取数据
  Future<Map<String, dynamic>> _readData() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      return {};
    }
  }

  bool isCollision() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (playground.getGridValue(
                  fallingPosition.x + j,
                  fallingPosition.y + i,
                ) +
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
            fallingPosition.x + j,
            fallingPosition.y + i,
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
        int fallingY = i - fallingPosition.y;
        int fallingX = j - fallingPosition.x;
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
    if(isShowAbout) {
      paintAbout(canvas, size);
    } else if (isGameOver) {
      paintGameOver(canvas, size);
    } else if (isPaused) {
      paintPause(canvas, size);
    }
  }

  List<Color> colors = [GameColors.gameOverText1, GameColors.gameOverText2];
  double colorIndex = 0;
  void _paintInfo(Canvas canvas, Size size, String title, String content) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: "$title\n",
          style: TextStyle(
            color: colors[((colorIndex += 0.05).toInt() % colors.length)],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: "\n$content\n",
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
  void paintGameOver(Canvas canvas, Size size) {
    _paintInfo(canvas, size, 'GAME OVER', 'Press Restart to play again');
  }
  
  void paintPause(Canvas canvas, Size size) {
    
    _paintInfo(canvas, size, 'PAUSED', 'Press Resume to continue');
  }
   
  void paintAbout(Canvas canvas, Size size) {
    _paintInfo(canvas, size, 'About Tetris', 'Version: 0.0.1\nProgrammed by Tinson\nSeptember 2025\n');
  }
}

class PreviewArea {
  Combination _previewCombination = CombinationFactory().createCombination();

  Combination getCombination() {
    Combination tmp = _previewCombination;
    _previewCombination = CombinationFactory().createCombination();
    return tmp;
  }

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
            j * brickSize.width,
            i * brickSize.height,
            brickSize.width - 1,
            brickSize.height - 1,
          ),
          _previewCombination.currentShape[i][j] == 0 ? paintBG : paintFG,
        );
      }
    }
  }
}
