import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


class CanvasCustomPainter extends CustomPainter {
  List<DrawPoint> points;
  Offset offset;

  CanvasCustomPainter({required this.points, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Colors.white;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //define the paint properties to be used for drawing
    Paint drawingPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black
      ..strokeWidth = 1.5;

    //a single line is defined as a series of points followed by a null at the end
    for (int x = 0; x < points.length - 1; x++) {
      //drawing line between the points to form a continuous line
      if (!points[x].empty && !points[x + 1].empty) {
        canvas.drawLine(
            points[x] + offset, points[x + 1] + offset, drawingPaint);
      }
      //if next point is null, means the line ends here
      else if (!points[x].empty && points[x + 1].empty) {
        canvas.drawPoints(PointMode.points, [points[x] + offset], drawingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}