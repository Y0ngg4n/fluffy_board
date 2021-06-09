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
  double _initcursorRadius = 50;
  Offset cursorPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          this.setState(() {
            _initialScale = scale;
            if (widget.selectedTool == SelectedTool.pencil ||
                widget.selectedTool == SelectedTool.straightLine) {
              Offset newOffset = (details.localFocalPoint - offset) / scale;
              scribbles.add(new Scribble(new List.filled(
                  1, new DrawPoint.of(newOffset),
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
            switch (widget.selectedTool) {
              case SelectedTool.move:
                _sessionOffset = details.focalPoint - _initialFocalPoint;
                break;
              case SelectedTool.eraser:
                int removeIndex = -1;
                for (int i = 0; i < scribbles.length; i++) {
                  List<Point> listOfPoints = scribbles[i]
                      .points
                      .map((e) => Point(e.dx, e.dy))
                      .toList();
                  listOfPoints = listOfPoints.smooth(listOfPoints.length * 5);
                  for (int p = 0; p < listOfPoints.length; p++) {
                    Point newDrawPoint = listOfPoints[p];
                    if (ScreenUtils.inCircle(
                        newDrawPoint.x.toInt(),
                        newOffset.dx.toInt(),
                        newDrawPoint.y.toInt(),
                        newOffset.dy.toInt(),
                        cursorRadius.toInt())) {
                      removeIndex = i;
                      break;
                    }
                  }
                  if (removeIndex != -1) {
                    scribbles.removeAt(removeIndex);
                    break;
                  }
                }
                break;
              case SelectedTool.straightLine:
                DrawPoint newDrawPoint =  new DrawPoint.of(newOffset);
                if(scribbles.last.points.length <= 1) scribbles.last.points.add(newDrawPoint);
                else scribbles.last.points.last = newDrawPoint;
                break;
              default:
                Scribble newScribble = scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                newScribble.points.add(newDrawPoint);
            }
          });
        },
        onScaleEnd: (details) {
          this.setState(() {
            offset += _sessionOffset;
            _sessionOffset = Offset.zero;
            if (widget.selectedTool == SelectedTool.pencil) {}
          });
        },
        child: SizedBox.expand(
          child: MouseRegion(
            onEnter: (event) {
              this.setState(() {
                cursorRadius = _initcursorRadius;
              });
            },
            onHover: (event) => {
              this.setState(() {
                cursorPosition = event.localPosition / scale;
              })
            },
            onExit: (event) {
              this.setState(() {
                cursorRadius = -1;
              });
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
