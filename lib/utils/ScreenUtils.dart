import 'package:flutter/material.dart';
import 'dart:ui';

class ScreenUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool inCircle(int x, int centerX, int y, int centerY, int radius) {
    int dx = (x - centerX).abs();
    int dy = (y - centerY).abs();
    int R = radius;

    if (dx + dy <= R) return true;
    if (dx > R) return false;
    if (dy > R) return false;
    if (dx ^ 2 + dy ^ 2 <= R ^ 2)
      return true;
    else
      return false;
  }
}
