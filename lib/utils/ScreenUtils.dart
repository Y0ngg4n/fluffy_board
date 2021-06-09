import 'package:fluffy_board/whiteboard/DrawPoint.dart';
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

  static bool checkIfNotInScreen(
      Scribble currentScribble,
      Offset calculatedOffset,
      double screenWidth,
      double screenHeight,
      double scale) {
    if ((currentScribble.leftExtremity == 0 ||
            currentScribble.rightExtremity == 0 ||
            currentScribble.topExtremity == 0 ||
            currentScribble.bottomExtremity == 0)) return false;

    return (currentScribble.leftExtremity + calculatedOffset.dx < 0 &&
                currentScribble.rightExtremity + calculatedOffset.dx < 0)
            // Check Right
            ||
            (currentScribble.rightExtremity + calculatedOffset.dx >
                    (screenWidth / scale) &&
                currentScribble.leftExtremity + calculatedOffset.dx >
                    (screenWidth / scale))
            // Check Top
            ||
            (currentScribble.topExtremity + calculatedOffset.dy < 0 &&
                currentScribble.bottomExtremity + calculatedOffset.dy < 0)
            //    Check Bottom
            ||
            (currentScribble.bottomExtremity + calculatedOffset.dy >
                    (screenHeight) / scale &&
                currentScribble.topExtremity + calculatedOffset.dy >
                    (screenHeight) / scale)
        ? true
        : false;
  }
}
