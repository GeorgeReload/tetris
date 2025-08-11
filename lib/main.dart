import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/game_area.dart';
import "package:tetris/repeat_button.dart";
import "package:tetris/game_colors.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PreviewArea? previewArea;
  GameArea? gameArea;
  @override
  void initState() {
    super.initState();
    previewArea = PreviewArea();
    gameArea = GameArea(previewArea!);
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      gameArea!.onTimer(10);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double squareSize = (MediaQuery.of(context).size.width - 150) / 10;
    Size size = Size(squareSize, squareSize);
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 50,
          bottom: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tetris',
              style: TextStyle(
                color: GameColors.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 10,
                  height: size.height * 22,
                  child: CustomPaint(
                    painter: SquarePainter(
                      brickSize: size,
                      gameArea: gameArea!,
                      previewArea: previewArea!,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 150),  //给预览区域留出空间
                    Text(
                      'Score',
                      style: TextStyle(
                        color: GameColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${gameArea!.score}',
                      style: TextStyle(color: GameColors.text, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 100),
                    Container(
                      color: GameColors.buttonBackground,
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: GameColors.buttonIcon,
                        ),
                        onPressed: () {
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      color: GameColors.buttonBackground,
                      child: IconButton(
                        icon: Icon(
                          Icons.restart_alt,
                          color: GameColors.buttonIcon,
                        ),
                        onPressed: () {
                          gameArea!.reset();
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      color: GameColors.buttonBackground,
                      child: IconButton(
                        icon: Icon(
                          gameArea!.isPaused ? Icons.play_arrow : Icons.pause,
                          color: GameColors.buttonIcon,
                        ),
                        onPressed: () {
                          gameArea!.pause();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  color: GameColors.buttonBackground,
                  child: RepeatIconButton(
                    icon: Icon(Icons.arrow_back, color: GameColors.buttonIcon),
                    onPressed: () {
                      gameArea!.moveLeft();
                    },
                  ),
                ),
                SizedBox(width: 30),
                Container(
                  color: GameColors.buttonBackground,
                  child: RepeatIconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: GameColors.buttonIcon,
                    ),
                    onPressed: () {
                      gameArea!.moveRight();
                    },
                  ),
                ),
                SizedBox(width: 50),
                Container(
                  color: GameColors.buttonBackground,
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: GameColors.buttonIcon),
                    onPressed: () {
                      gameArea!.rotate();
                    },
                  ),
                ),
                SizedBox(width: 30),
                Container(
                  color: GameColors.buttonBackground,
                  child: RepeatIconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: GameColors.buttonIcon,
                    ),
                    onPressed: () async {
                      gameArea!.moveDown();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SquarePainter extends CustomPainter {
  final Size brickSize;
  final GameArea gameArea;
  final PreviewArea previewArea;

  SquarePainter({
    required this.brickSize,
    required this.gameArea,
    required this.previewArea,
  });
  @override
  void paint(Canvas canvas, Size size) {
    gameArea.paint(canvas, size, brickSize);
    previewArea.paint(canvas, size, brickSize);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (gameArea.isGameOver) {
      return true;
    }
    if (gameArea.needRepaint) {
      gameArea.needRepaint = false;
      return true;
    }
    return false;
  }
}
