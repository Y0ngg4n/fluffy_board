import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CanvasCustomPainter extends CustomPainter {
  List<Scribble> scribbles;
  Offset offset;
  double scale;
  double cursorRadius;
  Offset cursorPosition;

  CanvasCustomPainter({
    required this.scribbles,
    required this.offset,
    required this.scale,
    required this.cursorRadius,
    required this.cursorPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Colors.white;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);
    canvas.scale(scale);

    //define the paint properties to be used for drawing
    Paint drawingPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black
      ..strokeWidth = 2;
    //a single line is defined as a series of points followed by a null at the end
    for (Scribble scribble in scribbles) {
      // DEBUG: Draw Points
      // canvas.drawPoints(PointMode.points, scribble.points, drawingPaint);
      for (int x = 0; x < scribble.points.length - 1; x++) {
        //drawing line between the points to form a continuous line
        if (!scribble.points[x].empty && !scribble.points[x + 1].empty) {
          canvas.drawLine(scribble.points[x] + offset,
              scribble.points[x + 1] + offset, drawingPaint);
        }
        //if next point is null, means the line ends here
        // else if (!scribble.points[x].empty && scribble.points[x + 1].empty) {
        //   canvas.drawPoints(
        //       PointMode.points, [scribble.points[x] + offset], drawingPaint);
        // }
      }
    }
    Paint cursorPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.blueGrey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Draw Cursor radius
    canvas.drawCircle(cursorPosition, cursorRadius, cursorPaint);
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}
