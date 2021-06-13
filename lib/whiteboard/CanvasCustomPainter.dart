import 'dart:math';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'overlays/Toolbar.dart' as Toolbar;

class CanvasCustomPainter extends CustomPainter {
  Toolbar.ToolbarOptions toolbarOptions;
  List<Scribble> scribbles;
  Offset offset;
  double scale;
  double cursorRadius;
  Offset cursorPosition;
  Offset screenSize;

  CanvasCustomPainter({
    required this.scribbles,
    required this.offset,
    required this.scale,
    required this.cursorRadius,
    required this.cursorPosition,
    required this.toolbarOptions,
    required this.screenSize,
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

    //a single line is defined as a series of points followed by a null at the end
    for (Scribble scribble in scribbles) {
      if (ScreenUtils.checkIfNotInScreen(
          scribble, offset, screenSize.dx, screenSize.dy, scale)) {
        continue;
      }

      Paint drawingPaint = Paint()
        ..strokeCap = scribble.strokeCap
        ..isAntiAlias = true
        ..color = scribble.color
        ..strokeWidth = scribble.strokeWidth;

      Paint figurePaint = drawingPaint..style = scribble.paintingStyle;
      switch (scribble.selectedFigureTypeToolbar) {
        case SelectedFigureTypeToolbar.rect:
          canvas.drawRect(
              Rect.fromLTWH(
                  scribble.points.first.dx + offset.dx,
                  scribble.points.first.dy + offset.dy,
                  scribble.points.last.dx -
                      scribble.points.first.dx,
                  scribble.points.last.dy -
                      scribble.points.first.dy),
              figurePaint);
          break;
        case SelectedFigureTypeToolbar.triangle:
          Path path = new Path();
          path.moveTo((scribble.points.first + offset).dx, (scribble.points.first + offset).dy);
          List<Offset> points = List.empty(growable: true);
          points.add(scribble.points.first + offset);
          points.add(scribble.points.last + offset);
          double distanceX = scribble.points.last.dx - scribble.points.first.dx;
          Offset leftPoint = new Offset(
              scribble.points.first.dx - distanceX, scribble.points.last.dy);
          points.add(leftPoint + offset);
          points.add(scribble.points.first + offset);
          path.addPolygon(points, true);
          canvas.drawPath(path, figurePaint);
          break;
        case SelectedFigureTypeToolbar.circle:
          double deltaX =
              scribble.points.last.dx - scribble.points.first.dx;
          double deltaY =
              scribble.points.last.dy - scribble.points.first.dy;
          double distance = sqrt((deltaX * deltaX) + (deltaY * deltaY));
          canvas.drawCircle(
              scribble.points.first + offset, distance, figurePaint);
          break;
        case SelectedFigureTypeToolbar.none:
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
            //       PointMode.points, [scribble.poinpts[x] + offset], drawingPaint);
            // }
          }
          break;
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
