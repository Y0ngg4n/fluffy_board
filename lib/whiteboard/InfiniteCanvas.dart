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
import 'overlays/Toolbar.dart' as Toolbar;
import 'overlays/Zoom.dart' as Zoom;

class InfiniteCanvasPage extends StatefulWidget {
  Zoom.OnChangedZoomOptions onChangedZoomOptions;
  Toolbar.ToolbarOptions toolbarOptions;
  Zoom.ZoomOptions zoomOptions;
  double appBarHeight;

  InfiniteCanvasPage({
    required this.toolbarOptions,
    required this.zoomOptions,
    required this.onChangedZoomOptions,
    required this.appBarHeight,
  });

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<Scribble> scribbles = [];
  double _initialScale = 0.5;
  Offset offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  Offset cursorPosition = Offset.zero;
  late double cursorRadius;
  late double _initcursorRadius;

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtils.getScreenWidth(context);
    double screenHeight = ScreenUtils.getScreenHeight(context);
    cursorRadius = _getCursorRadius() / 2;
    _initcursorRadius = _getCursorRadius() / 2;

    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          this.setState(() {
            _initialScale = widget.zoomOptions.scale;
            if (widget.toolbarOptions.selectedTool == SelectedTool.pencil ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.straightLine) {
              Offset newOffset =
                  (details.localFocalPoint - offset) / widget.zoomOptions.scale;
              scribbles.add(_getScribble(newOffset));
            } else {
              _initialFocalPoint = details.focalPoint;
            }
          });
        },
        onScaleUpdate: (details) {
          Offset newOffset =
              (details.localFocalPoint - offset) / widget.zoomOptions.scale;
          this.setState(() {
            cursorPosition = details.localFocalPoint / widget.zoomOptions.scale;
            widget.zoomOptions.scale = details.scale * _initialScale;
            widget.onChangedZoomOptions(widget.zoomOptions);
            switch (widget.toolbarOptions.selectedTool) {
              case SelectedTool.move:
                _sessionOffset = details.focalPoint - _initialFocalPoint;
                // print(_calculateOffset(offset, _sessionOffset, scale));
                break;
              case SelectedTool.eraser:
                int removeIndex = -1;
                Offset calculatedOffset = _calculateOffset(
                    offset, _sessionOffset, widget.zoomOptions.scale);
                for (int i = 0; i < scribbles.length; i++) {
                  // Check in viewport
                  Scribble currentScribble = scribbles[i];
                  if (ScreenUtils.checkIfNotInScreen(
                      currentScribble,
                      calculatedOffset,
                      screenWidth,
                      screenHeight,
                      widget.zoomOptions.scale)) {
                    continue;
                  }
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
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                if (scribbles.last.points.length <= 1)
                  scribbles.last.points.add(newDrawPoint);
                else
                  scribbles.last.points.last = newDrawPoint;
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
            if (widget.toolbarOptions.selectedTool == SelectedTool.pencil) {
              Scribble newScribble = scribbles.last;
              for (int i = 0; i < newScribble.points.length; i++) {
                DrawPoint drawPoint = newScribble.points[i];
                if (i == 0) {
                  newScribble.leftExtremity = drawPoint.dx;
                  newScribble.rightExtremity = drawPoint.dx;
                  newScribble.topExtremity = drawPoint.dy;
                  newScribble.bottomExtremity = drawPoint.dy;
                } else {
                  if (drawPoint.dx <= newScribble.leftExtremity)
                    newScribble.leftExtremity = newScribble.points[i].dx;
                  else if (drawPoint.dx > newScribble.rightExtremity) {
                    newScribble.rightExtremity = newScribble.points[i].dx;
                  }

                  if (drawPoint.dy > newScribble.bottomExtremity)
                    newScribble.bottomExtremity = drawPoint.dy;
                  else if (drawPoint.dy <= newScribble.topExtremity) {
                    newScribble.topExtremity = drawPoint.dy;
                  }
                }
              }
              scribbles.last = newScribble;
            }
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
                cursorPosition = event.localPosition / widget.zoomOptions.scale;
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
                    offset: _calculateOffset(
                        offset, _sessionOffset, widget.zoomOptions.scale),
                    scale: widget.zoomOptions.scale,
                    cursorRadius: cursorRadius,
                    cursorPosition: cursorPosition,
                    toolbarOptions: widget.toolbarOptions,
                    screenSize: new Offset(screenWidth, screenHeight)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _calculateOffset(Offset offset, Offset _sessionOffset, double scale) {
    return (offset + _sessionOffset) / scale;
  }

  _getScribble(Offset newOffset) {
    List<DrawPoint> drawPoints =
        new List.filled(1, new DrawPoint.of(newOffset), growable: true);
    Color color = Colors.black;
    StrokeCap strokeCap = StrokeCap.round;
    double strokeWidth = 1;
    if (widget.toolbarOptions.selectedTool == SelectedTool.pencil) {
      color = widget.toolbarOptions.pencilOptions
          .colorPresets[widget.toolbarOptions.pencilOptions.currentColor];
      strokeWidth = widget.toolbarOptions.pencilOptions.strokeWidth;
      strokeCap = StrokeCap.round;
    } else if (widget.toolbarOptions.selectedTool == SelectedTool.pencil) {
      strokeCap = StrokeCap.square;
    }
    return new Scribble(strokeWidth, strokeCap, color, drawPoints);
  }

  double _getCursorRadius() {
    double cursorRadius;
    switch (widget.toolbarOptions.selectedTool) {
      case SelectedTool.pencil:
        cursorRadius = widget.toolbarOptions.pencilOptions.strokeWidth;
        break;
      default:
        cursorRadius = widget.toolbarOptions.pencilOptions.strokeWidth;
        break;
    }
    return cursorRadius;
  }
}
