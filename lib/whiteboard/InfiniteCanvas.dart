import 'dart:io';
import 'dart:math';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
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
                    SelectedTool.highlighter ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.straightLine ||
                widget.toolbarOptions.selectedTool == SelectedTool.figure) {
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
                Scribble lastScribble = scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                if (lastScribble.points.length <= 1)
                  lastScribble.points.add(newDrawPoint);
                else
                  lastScribble.points
                      .removeRange(2, lastScribble.points.length);
                lastScribble.points.last = newDrawPoint;
                if (widget.toolbarOptions.straightLineOptions
                        .selectedStraightLineCapToolbar ==
                    SelectedStraightLineCapToolbar.Arrow)
                  fillArrow(
                      lastScribble.points.first.dx,
                      lastScribble.points.first.dy,
                      lastScribble.points[1].dx,
                      lastScribble.points[1].dy,
                      lastScribble.points,
                      widget.toolbarOptions.straightLineOptions.strokeWidth +
                          10);
                break;
              case SelectedTool.figure:
                Scribble lastScribble = scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                if (lastScribble.points.length <= 1)
                  lastScribble.points.add(newDrawPoint);
                else
                  lastScribble.points.last = newDrawPoint;
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

            if (widget.toolbarOptions.selectedTool == SelectedTool.pencil ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.highlighter ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.straightLine) {
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
    SelectedFigureTypeToolbar selectedFigureTypeToolbar =
        SelectedFigureTypeToolbar.none;
    PaintingStyle paintingStyle = PaintingStyle.stroke;
    if (widget.toolbarOptions.selectedTool == SelectedTool.pencil) {
      color = widget.toolbarOptions.pencilOptions
          .colorPresets[widget.toolbarOptions.pencilOptions.currentColor];
      strokeWidth = widget.toolbarOptions.pencilOptions.strokeWidth;
      strokeCap = widget.toolbarOptions.pencilOptions.strokeCap;
    } else if (widget.toolbarOptions.selectedTool == SelectedTool.highlighter) {
      color = widget.toolbarOptions.highlighterOptions
          .colorPresets[widget.toolbarOptions.highlighterOptions.currentColor];
      strokeWidth = widget.toolbarOptions.highlighterOptions.strokeWidth;
      strokeCap = widget.toolbarOptions.highlighterOptions.strokeCap;
    } else if (widget.toolbarOptions.selectedTool ==
        SelectedTool.straightLine) {
      color = widget.toolbarOptions.straightLineOptions
          .colorPresets[widget.toolbarOptions.straightLineOptions.currentColor];
      strokeWidth = widget.toolbarOptions.straightLineOptions.strokeWidth;
      strokeCap = widget.toolbarOptions.straightLineOptions.strokeCap;
    } else if (widget.toolbarOptions.selectedTool == SelectedTool.eraser) {
      strokeWidth = widget.toolbarOptions.eraserOptions.strokeWidth;
    } else if (widget.toolbarOptions.selectedTool == SelectedTool.figure) {
      strokeWidth = widget.toolbarOptions.figureOptions.strokeWidth;
      color = widget.toolbarOptions.figureOptions
          .colorPresets[widget.toolbarOptions.figureOptions.currentColor];
      selectedFigureTypeToolbar =
          widget.toolbarOptions.figureOptions.selectedFigureTypeToolbar;
      paintingStyle = widget.toolbarOptions.figureOptions.paintingStyle;
    }

    return new Scribble(strokeWidth, strokeCap, color, drawPoints,
        selectedFigureTypeToolbar, paintingStyle);
  }

  double _getCursorRadius() {
    double cursorRadius;
    switch (widget.toolbarOptions.selectedTool) {
      case SelectedTool.pencil:
        cursorRadius = widget.toolbarOptions.pencilOptions.strokeWidth;
        break;
      case SelectedTool.highlighter:
        cursorRadius = widget.toolbarOptions.highlighterOptions.strokeWidth;
        break;
      case SelectedTool.straightLine:
        cursorRadius = widget.toolbarOptions.straightLineOptions.strokeWidth;
        break;
      case SelectedTool.eraser:
        cursorRadius = widget.toolbarOptions.eraserOptions.strokeWidth;
        break;
      default:
        cursorRadius = widget.toolbarOptions.pencilOptions.strokeWidth;
        break;
    }
    return cursorRadius;
  }

  fillArrow(double x0, double y0, double x1, double y1, List<DrawPoint> list,
      length) {
    double deltaX = x1 - x0;
    double deltaY = y1 - y0;
    double distance = sqrt((deltaX * deltaX) + (deltaY * deltaY));
    double frac = (1 / (distance / length));

    double point_x_1 = x0 + ((1 - frac) * deltaX + frac * deltaY);
    double point_y_1 = y0 + ((1 - frac) * deltaY - frac * deltaX);

    double point_x_3 = x0 + ((1 - frac) * deltaX - frac * deltaY);
    double point_y_3 = y0 + ((1 - frac) * deltaY + frac * deltaX);

    list.add(new DrawPoint(x1, y1));
    list.add(new DrawPoint(point_x_1, point_y_1));
    list.add(new DrawPoint(x1, y1));
    list.add(new DrawPoint(point_x_3, point_y_3));
    list.add(new DrawPoint(x1, y1));
    // path.lineTo(point_x_3, point_y_3);
    // path.lineTo(point_x_1, point_y_1);
    // path.lineTo(point_x_1, point_y_1);
  }
}
