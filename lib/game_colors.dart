import 'package:flutter/material.dart';

abstract final class GameColors {
  static const Color background = Color.fromARGB(255, 228, 244, 255);        // 浅暖白
  static const Color gameAreaGrid = Color.fromRGBO(207, 210, 219, 1);       // 米灰格线
  static const Color gameAreaNullSquare = Color.fromARGB(255, 228, 244, 255); // 空格同背景
  static const Color gameAreaSquare = Color.fromARGB(255, 255, 174, 72);     // 柔和亮橙（主色方块）
  static const Color buttonIcon = Color.fromARGB(255, 255, 232, 40);         // 明亮蓝按钮图标
  static const Color buttonBackground = Color.fromARGB(255, 40, 197, 179);
  static const Color text = Color.fromARGB(255, 71, 95, 115);               // 深灰文字
  static const Color gameOverText1 = Color.fromARGB(255, 71, 95, 115);       // 同文字色
  static const Color gameOverText2 = Color.fromARGB(255, 149, 75, 191);       // 紫色游戏结束提示
}

/*
abstract final class GameColors {
  static const Color background = Color(0xFFFAFAF5);        // 浅暖白
  static const Color gameAreaGrid = Color(0xFFE0DED6);       // 米灰格线
  static const Color gameAreaNullSquare = Color(0xFFFAFAF5); // 空格同背景
  static const Color gameAreaSquare = Color(0xFFFFB84D);     // 柔和亮橙（主色方块）
  static const Color buttonIcon = Color(0xFF4D9FFF);         // 明亮蓝按钮图标
  static const Color buttonBackground = Color(0xFFE0DED6);
  static const Color text = Color(0xFF666666);               // 深灰文字
  static const Color gameOverText1 = Color(0xFF666666);       // 同文字色
  static const Color gameOverText2 = Color(0xFF4D9FFF);       // 紫色游戏结束提示
}

abstract final class GameColors_Duobaan { // 多巴胺
  static const Color background = Color(0xFFFFF6E8);        // 温暖奶黄色背景
  static const Color gameAreaGrid = Color(0xFFFFA07A);       // 亮橙网格线
  static const Color gameAreaNullSquare = Color(0xFFFFF6E8); // 空格同背景
  static const Color gameAreaSquare = Color(0xFF00C853);     // 高饱和活力绿（方块）
  static const Color buttonIcon = Color(0xFF1E3AFF);         // 明亮宝蓝按钮图标
  static const Color buttonBackground = Color(0xFFFFC8C8);
  static const Color text = Color(0xFFE91E63);               // 亮粉色文字
  static const Color gameOverText = Color(0xFFE91E63);       // 同亮粉
}
abstract final class GameColors_Morandi { // 莫兰迪
  static const Color background = Color(0xFFFFF9F4);        // 奶油白
  static const Color gameAreaGrid = Color(0xFFEADFD9);       // 浅灰米色网格线
  static const Color gameAreaNullSquare = Color(0xFFFFF9F4); // 空格与背景一致
  static const Color gameAreaSquare = Color(0xFFAACDE7);     // 柔和天蓝
  static const Color buttonIcon = Color(0xFF7B7B7B);         // 中性灰按钮图标
  static const Color buttonBackground = Color(0xFFFFC8C8);
  static const Color text = Color(0xFF7A7070);               // 柔和灰棕文字
  static const Color gameOverText = Color(0xFF7A7070);       // 同文字颜色
}
abstract final class GameColors_Macarons { // 玛卡龙
  static const Color background = Color(0xFFF7F5F2);
  static const Color gameAreaGrid = Color(0xFFE5E2DD);
  static const Color gameAreaNullSquare = Color(0xFFF7F5F2);
  static const Color gameAreaSquare = Color(0xFF7ADBCF);
  static const Color buttonIcon = Color(0xFF555555); //0xFF555555
  static const Color buttonBackground = Color(0xFFFFC8C8);
  static const Color text = Color(0xFF666666);
  static const Color gameOverText = Color(0xFF666666);
}
*/