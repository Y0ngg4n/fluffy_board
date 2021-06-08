import 'dart:io';
import 'dart:math';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smoothing/smoothing.dart';
import 'package:smoothie/smoothie.dart';

import 'CanvasCustomPainter.dart';

class InfiniteCanvasPage extends StatefulWidget {
  SelectedTool selectedTool;

  InfiniteCanvasPage(this.selectedTool);

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<Scribble> scribbles = [];
  double scale = 0.5;
  double _initialScale = 0.5;
  Offset offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  double cursorRadius = 50;
  Offset cursorPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          this.setState(() {
            _initialScale = scale;
            if (widget.selectedTool == SelectedTool.pencil) {
              Offset newOffset = (details.localFocalPoint - offset) / scale;
              scribbles.add(new Scribble(new List.filled(
                  1, new DrawPoint(newOffset.dx, newOffset.dy),
                  growable: true)));
            } else {
              _initialFocalPoint = details.focalPoint;
            }
          });
        },
        onScaleUpdate: (details) {
          Offset newOffset = (details.localFocalPoint - offset) / scale;
          this.setState(() {
            cursorPosition = details.localFocalPoint / scale;
            scale = details.scale * _initialScale;
            if (widget.selectedTool == SelectedTool.move) {
              // offset += details.localFocalPoint - offset;
              _sessionOffset = details.focalPoint - _initialFocalPoint;
              // offset = new Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            } else if (widget.selectedTool == SelectedTool.eraser) {
              int removeIndex = -1;

              for (int i = 0; i < scribbles.length; i++) {
                for (int p = 0; p < scribbles[i].points.length; p++) {
                  DrawPoint newDrawPoint = scribbles[i].points[p];
                  List<DrawPoint> eraserPoint = new List.empty(growable: true);
                  eraserPoint.add(newDrawPoint);
                  if (p > 1) {
                    DrawPoint beforeDrawPoint = scribbles[i].points[p - 1];
                    for (int z = 0; z < 3; z++) {
                      double x = newDrawPoint.dx - beforeDrawPoint.dx;
                      double y = newDrawPoint.dy - beforeDrawPoint.dy;
                      eraserPoint.add(new DrawPoint(
                          beforeDrawPoint.dx + x * (z / 3),
                          beforeDrawPoint.dy + y * (z / 3)));
                    }
                  }
                  for (DrawPoint drawPoint in eraserPoint) {
                    if (ScreenUtils.inCircle(
                        drawPoint.dx.toInt(),
                        newOffset.dx.toInt(),
                        drawPoint.dy.toInt(),
                        newOffset.dy.toInt(),
                        cursorRadius.toInt())) {
                      removeIndex = i;
                      break;
                    }
                    // Old calculation (Thank you Max :) )
                    // if ((newOffset.dx - drawPoint.dx).abs() < volatility &&
                    //     (newOffset.dy - drawPoint.dy).abs() < volatility) {
                    //   print("IFFFFFFF");
                    //   removeIndex = i;
                    //   break;
                    // }
                    // if ((newOffset.dx - drawPoint.dx).abs() < volatility &&
                    //     (newOffset.dy - drawPoint.dy).abs() < volatility) {
                    //   print("IFFFFFFF");
                    //   removeIndex = i;
                    //   break;
                    // }
                  }
                  if (removeIndex != -1) {
                    scribbles.removeAt(removeIndex);
                    break;
                  }
                }
                if (removeIndex != -1) break;
              }
            } else {
              Scribble newScribble = scribbles.last;
              DrawPoint newDrawPoint =
                  new DrawPoint(newOffset.dx, newOffset.dy);
              newScribble.points.add(newDrawPoint);
            }
          });
        },
        onScaleEnd: (details) {
          this.setState(() {
            offset += _sessionOffset;
            _sessionOffset = Offset.zero;
            if (widget.selectedTool == SelectedTool.pencil) {
              SgFilter filter = new SgFilter(3, 11);
              setState(() {
                Scribble lastScribble = scribbles.last;
                // List<dynamic> x = lastScribble.points.map((e) => e.dx).toList();
                // List<dynamic> y = lastScribble.points.map((e) => e.dy).toList();
                // x = filter.smooth(x);
                // y = filter.smooth(y);
                List<Point> listOfPoints = lastScribble.points.map((e) => Point(e.dx, e.dy)).toList();
                // listOfPoints = listOfPoints.smooth(listOfPoints.length * 5);
                List<DrawPoint> drawPoints = new List<DrawPoint>.empty(growable: true);
                for(int i = 0; i < listOfPoints.length; i++){
                  for (int z = 0; z < 3; z++) {
                    if (i> 2){
                      num x = listOfPoints[i].x - listOfPoints[i-1].y;
                      num y = listOfPoints[i].y - listOfPoints[i-1].y;

                      drawPoints.add(new DrawPoint(
                          listOfPoints[i-1].x + x * (z / 3),
                          listOfPoints[i-1].y + y * (z / 3)));
                    }
                  }
                  drawPoints.add(new DrawPoint(listOfPoints[i].x.toDouble(), listOfPoints[i].y.toDouble()));
                }
                lastScribble.points = drawPoints;
              });
            }
          });
        },
        child: SizedBox.expand(
          child: MouseRegion(
            onHover: (event) => {
              this.setState(() {
                cursorPosition = event.localPosition / scale;
              })
            },
            child: ClipRRect(
              child: CustomPaint(
                painter: CanvasCustomPainter(
                  scribbles: scribbles,
                  offset: (offset + _sessionOffset) / scale,
                  scale: scale,
                  cursorRadius: cursorRadius,
                  cursorPosition: cursorPosition,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
