import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smoothie/smoothie.dart';

import 'CanvasCustomPainter.dart';
import 'Websocket/WebsocketConnection.dart';
import 'Websocket/WebsocketTypes.dart';
import 'overlays/Toolbar.dart' as Toolbar;
import 'overlays/Zoom.dart' as Zoom;
import 'package:uuid/uuid.dart';

typedef OnOffsetChange = Function(Offset offset, Offset sessionOffset);
typedef OnScribblesChange = Function(List<Scribble>);
typedef OnUploadsChange = Function(List<Upload>);
typedef OnTextItemsChange = Function(List<TextItem>);
typedef OnChangedToolbarOptions<T> = Function(Toolbar.ToolbarOptions);

class InfiniteCanvasPage extends StatefulWidget {
  Zoom.OnChangedZoomOptions onChangedZoomOptions;
  Toolbar.ToolbarOptions toolbarOptions;
  Zoom.ZoomOptions zoomOptions;
  double appBarHeight;
  List<Upload> uploads;
  List<TextItem> texts;
  List<Scribble> scribbles;
  Offset offset;
  Offset sessionOffset;
  OnOffsetChange onOffsetChange;
  OnChangedToolbarOptions onChangedToolbarOptions;
  OnScribblesChange onScribblesChange;
  WebsocketConnection? websocketConnection;
  String auth_token;
  OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;

  InfiniteCanvasPage(
      {required this.toolbarOptions,
      required this.zoomOptions,
      required this.onChangedZoomOptions,
      required this.appBarHeight,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.onOffsetChange,
      required this.onChangedToolbarOptions,
      required this.texts,
      required this.scribbles,
      required this.onScribblesChange,
      required this.websocketConnection,
      required this.auth_token,
      required this.onSaveOfflineWhiteboard});

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  double _initialScale = 0.5;
  Offset _initialFocalPoint = Offset.zero;
  Offset cursorPosition = Offset.zero;
  Offset onSettingsMove = Offset.zero;
  List<DrawPoint> onSettingsMovePoints = [];
  Offset? onSettingsMoveUploadOffset;
  Offset? onSettingsMoveTextItemOffset;
  late double cursorRadius;
  late double _initcursorRadius;
  var uuid = Uuid();
  bool multiSelect = false;
  bool multiSelectMove = false;
  Offset multiSelectStartPosition = Offset.zero;
  Offset multiSelectStopPosition = Offset.zero;
  Map<Scribble, List<DrawPoint>> selectedMultiScribblesOffsets = new Map();
  List<Scribble> selectedMultiScribbles = [];
  Offset multiSelectMoveOffset = Offset.zero;

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
            Offset newOffset = (details.localFocalPoint - widget.offset) /
                widget.zoomOptions.scale;
            if (widget.toolbarOptions.selectedTool == SelectedTool.pencil ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.highlighter ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.straightLine ||
                widget.toolbarOptions.selectedTool == SelectedTool.figure) {
              Scribble newScribble = _getScribble(newOffset);
              widget.scribbles.add(newScribble);
              WebsocketSend.sendCreateScribble(
                  newScribble, widget.websocketConnection);
              widget.onScribblesChange(widget.scribbles);
              multiSelect = false;
            } else if (widget.toolbarOptions.selectedTool ==
                SelectedTool.text) {
              TextItem textItem = new TextItem(
                  uuid.v4(),
                  true,
                  widget.toolbarOptions.textOptions.strokeWidth,
                  ScreenUtils.getScreenWidth(context).toInt(),
                  ScreenUtils.getScreenHeight(context).toInt(),
                  widget.toolbarOptions.textOptions.colorPresets[
                      widget.toolbarOptions.textOptions.currentColor],
                  "",
                  newOffset);
              widget.texts.add(textItem);
              WebsocketSend.sendCreateTextItem(
                  textItem, widget.websocketConnection);
              multiSelect = false;
            } else if (widget.toolbarOptions.selectedTool ==
                SelectedTool.settings) {
              Offset calculatedOffset = _calculateOffset(widget.offset,
                  widget.sessionOffset, widget.zoomOptions.scale);
              bool found = false;
              // Check Scribbles
              for (int i = 0; i < widget.scribbles.length; i++) {
                // Check in viewport
                Scribble currentScribble = widget.scribbles[i];
                if (ScreenUtils.checkScribbleIfNotInScreen(
                    currentScribble,
                    calculatedOffset,
                    screenWidth,
                    screenHeight,
                    widget.zoomOptions.scale)) {
                  continue;
                }
                List<Point> listOfPoints = widget.scribbles[i].points
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
                      10)) {
                    found = true;
                    widget.toolbarOptions.settingsSelectedScribble =
                        currentScribble;
                    widget.toolbarOptions.settingsSelected =
                        SettingsSelected.scribble;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    onSettingsMove = newOffset;
                    onSettingsMovePoints = currentScribble.points;
                    break;
                  }
                }
              }
              if (found) return;
              // Check uploads
              for (Upload upload in widget.uploads) {
                // Check if image
                if (upload.image != null) {
                  if (ScreenUtils.inRect(
                      Rect.fromLTWH(
                          upload.offset.dx,
                          upload.offset.dy,
                          upload.image!.width.toDouble(),
                          upload.image!.height.toDouble()),
                      newOffset)) {
                    found = true;
                    widget.toolbarOptions.settingsSelectedUpload = upload;
                    widget.toolbarOptions.settingsSelected =
                        SettingsSelected.image;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    onSettingsMove = newOffset;
                    onSettingsMoveUploadOffset = upload.offset;
                    break;
                  }
                }
              }
              if (found) return;
              for (TextItem textItem in widget.texts) {
                TextPainter textPainter = ScreenUtils.getTextPainter(textItem);
                if (ScreenUtils.inRect(
                    Rect.fromLTWH(textItem.offset.dx, textItem.offset.dy,
                        textPainter.width, textPainter.height),
                    newOffset)) {
                  if (widget.toolbarOptions.settingsSelectedTextItem != null &&
                      widget.toolbarOptions.settingsSelectedTextItem!.uuid ==
                          textItem.uuid) {
                    textItem.editing = true;
                  }
                  found = true;
                  widget.toolbarOptions.settingsSelectedTextItem = textItem;
                  widget.toolbarOptions.settingsSelected =
                      SettingsSelected.text;
                  widget.onChangedToolbarOptions(widget.toolbarOptions);
                  onSettingsMove = newOffset;
                  onSettingsMoveTextItemOffset = textItem.offset;
                  break;
                }
              }
              if (found) return;
              if (multiSelectStartPosition != Offset.zero &&
                  multiSelectStopPosition != Offset.zero &&
                  ScreenUtils.inRect(
                      Rect.fromPoints(
                          multiSelectStartPosition, multiSelectStopPosition),
                      newOffset)) {
                widget.toolbarOptions.settingsSelected =
                    SettingsSelected.none;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
                multiSelectMoveOffset = newOffset;
                multiSelectMove = true;
              } else {
                widget.toolbarOptions.settingsSelected =
                    SettingsSelected.none;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
                multiSelect = true;
                multiSelectMove = false;
                multiSelectStartPosition = newOffset;
                multiSelectStopPosition = newOffset;
              }
            } else {
              _initialFocalPoint = details.focalPoint;
              for (TextItem textItem in widget.texts) {
                textItem.editing = false;
              }
              multiSelect = false;
              widget.toolbarOptions.settingsSelectedTextItem = null;
              widget.toolbarOptions.settingsSelectedUpload = null;
              widget.toolbarOptions.settingsSelectedScribble = null;
              widget.onChangedToolbarOptions(widget.toolbarOptions);
            }
          });
        },
        onScaleUpdate: (details) {
          Offset newOffset = (details.localFocalPoint - widget.offset) /
              widget.zoomOptions.scale;
          this.setState(() {
            cursorPosition = details.localFocalPoint / widget.zoomOptions.scale;
            widget.zoomOptions.scale = details.scale * _initialScale;
            widget.onChangedZoomOptions(widget.zoomOptions);
            switch (widget.toolbarOptions.selectedTool) {
              case SelectedTool.move:
                // TODO: Test on mobile
                if (details.pointerCount == 2) {
                  widget.sessionOffset =
                      details.focalPoint * 3 - _initialFocalPoint;
                } else {
                  widget.sessionOffset =
                      details.focalPoint - _initialFocalPoint;
                }
                widget.onOffsetChange(widget.offset, widget.sessionOffset);
                break;
              case SelectedTool.background:
                break;
              case SelectedTool.eraser:
                int removeIndex = -1;
                Offset calculatedOffset = _calculateOffset(widget.offset,
                    widget.sessionOffset, widget.zoomOptions.scale);
                for (int i = 0; i < widget.scribbles.length; i++) {
                  // Check in viewport
                  Scribble currentScribble = widget.scribbles[i];
                  if (ScreenUtils.checkScribbleIfNotInScreen(
                      currentScribble,
                      calculatedOffset,
                      screenWidth,
                      screenHeight,
                      widget.zoomOptions.scale)) {
                    continue;
                  }
                  List<Point> listOfPoints = widget.scribbles[i].points
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
                    WebsocketSend.sendScribbleDelete(
                        currentScribble, widget.websocketConnection);
                    widget.scribbles.removeAt(removeIndex);
                    break;
                  }
                }
                break;
              case SelectedTool.straightLine:
                Scribble lastScribble = widget.scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                if (lastScribble.points.length <= 1)
                  lastScribble.points.add(newDrawPoint);
                else
                  lastScribble.points
                      .removeRange(2, lastScribble.points.length);
                lastScribble.points.last = newDrawPoint;
                if (SelectedStraightLineCapToolbar.values[widget
                        .toolbarOptions.straightLineOptions.selectedCap] ==
                    SelectedStraightLineCapToolbar.Arrow)
                  fillArrow(
                      lastScribble.points.first.dx,
                      lastScribble.points.first.dy,
                      lastScribble.points[1].dx,
                      lastScribble.points[1].dy,
                      lastScribble.points,
                      widget.toolbarOptions.straightLineOptions.strokeWidth +
                          10);
                WebsocketSend.sendScribbleUpdate(
                    lastScribble, widget.websocketConnection);
                break;
              case SelectedTool.figure:
                Scribble lastScribble = widget.scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                if (lastScribble.points.length <= 1)
                  lastScribble.points.add(newDrawPoint);
                else
                  lastScribble.points.last = newDrawPoint;
                WebsocketSend.sendScribbleUpdate(
                    lastScribble, widget.websocketConnection);
                break;
              case SelectedTool.settings:
                if (widget.toolbarOptions.settingsSelected ==
                        SettingsSelected.scribble &&
                    widget.toolbarOptions.settingsSelectedScribble != null &&
                    onSettingsMovePoints.isNotEmpty) {
                  List<DrawPoint> newPoints = List.empty(growable: true);
                  for (DrawPoint drawPoint in onSettingsMovePoints) {
                    newPoints.add(new DrawPoint.of(
                        drawPoint + (newOffset - onSettingsMove)));
                  }
                  widget.toolbarOptions.settingsSelectedScribble!.points =
                      newPoints;
                  ScreenUtils.calculateScribbleBounds(
                      widget.toolbarOptions.settingsSelectedScribble!);
                  WebsocketSend.sendScribbleUpdate(
                      widget.toolbarOptions.settingsSelectedScribble!,
                      widget.websocketConnection);
                } else if (widget.toolbarOptions.settingsSelected ==
                        SettingsSelected.image &&
                    widget.toolbarOptions.settingsSelectedUpload != null &&
                    onSettingsMoveUploadOffset != null) {
                  widget.toolbarOptions.settingsSelectedUpload!.offset =
                      (onSettingsMoveUploadOffset! +
                          (newOffset - onSettingsMove));
                  WebsocketSend.sendUploadUpdate(
                      widget.toolbarOptions.settingsSelectedUpload!,
                      widget.websocketConnection);
                } else if (widget.toolbarOptions.settingsSelected ==
                        SettingsSelected.text &&
                    widget.toolbarOptions.settingsSelectedTextItem != null &&
                    onSettingsMoveTextItemOffset != null) {
                  widget.toolbarOptions.settingsSelectedTextItem!.offset =
                      (onSettingsMoveTextItemOffset! +
                          (newOffset - onSettingsMove));
                  WebsocketSend.sendUpdateTextItem(
                      widget.toolbarOptions.settingsSelectedTextItem!,
                      widget.websocketConnection);
                } else if (widget.toolbarOptions.settingsSelected ==
                    SettingsSelected.none) {}
                {
                  if (multiSelect && !multiSelectMove) {
                    multiSelectStopPosition = newOffset;
                  }
                  if (multiSelectMove) {
                    for (Scribble scribble in selectedMultiScribbles) {
                      List<DrawPoint> newPoints = List.empty(growable: true);
                      for (int i = 0; i < scribble.points.length; i++) {
                        newPoints.add(new DrawPoint.of(
                            selectedMultiScribblesOffsets[scribble]![i] +
                                (newOffset - multiSelectMoveOffset)));
                      }
                      scribble.points = newPoints;
                    }
                    widget.onScribblesChange(widget.scribbles);
                  }
                }
                widget.onChangedToolbarOptions(widget.toolbarOptions);
                break;
              default:
                Scribble newScribble = widget.scribbles.last;
                DrawPoint newDrawPoint = new DrawPoint.of(newOffset);
                newScribble.points.add(newDrawPoint);
                WebsocketSend.sendScribbleUpdate(
                    newScribble, widget.websocketConnection);
            }
          });
        },
        onScaleEnd: (details) {
          this.setState(() {
            widget.offset += widget.sessionOffset;
            widget.sessionOffset = Offset.zero;
            widget.onOffsetChange(widget.offset, widget.sessionOffset);
            onSettingsMove = Offset.zero;
            onSettingsMovePoints = [];
            widget.onChangedToolbarOptions(widget.toolbarOptions);
            if (widget.toolbarOptions.selectedTool == SelectedTool.pencil ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.highlighter ||
                widget.toolbarOptions.selectedTool ==
                    SelectedTool.straightLine) {
              Scribble newScribble = widget.scribbles.last;
              ScreenUtils.calculateScribbleBounds(newScribble);
              widget.scribbles.last = newScribble;
              WebsocketSend.sendScribbleUpdate(
                  newScribble, widget.websocketConnection);
              widget.onSaveOfflineWhiteboard();
            } else if (widget.toolbarOptions.selectedTool ==
                    SelectedTool.settings &&
                widget.toolbarOptions.settingsSelected ==
                    SettingsSelected.none) {
              for (Scribble scribble in widget.scribbles) {
                if (multiSelect && !multiSelectMove) {
                  for (DrawPoint drawPoint in scribble.points) {
                    if (ScreenUtils.inRect(
                        Rect.fromPoints(
                            multiSelectStartPosition, multiSelectStopPosition),
                        drawPoint)) {
                      selectedMultiScribbles.add(scribble);
                      selectedMultiScribblesOffsets[scribble] = scribble.points
                          .map((e) => new DrawPoint(e.dx, e.dy))
                          .toList();
                      continue;
                    }
                  }
                }
                if (multiSelectMove) {
                  ScreenUtils.calculateScribbleBounds(scribble);
                  WebsocketSend.sendScribbleUpdate(
                      scribble, widget.websocketConnection);
                }
              }
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
                    texts: widget.texts,
                    uploads: widget.uploads,
                    scribbles: widget.scribbles,
                    offset: _calculateOffset(widget.offset,
                        widget.sessionOffset, widget.zoomOptions.scale),
                    scale: widget.zoomOptions.scale,
                    cursorRadius: cursorRadius,
                    cursorPosition: cursorPosition,
                    toolbarOptions: widget.toolbarOptions,
                    screenSize: new Offset(screenWidth, screenHeight),
                    multiSelect: multiSelect,
                    multiSelectMove: multiSelectMove,
                    multiSelectStartPosition: multiSelectStartPosition,
                    multiSelectStopPosition: multiSelectStopPosition),
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
      selectedFigureTypeToolbar = SelectedFigureTypeToolbar
          .values[widget.toolbarOptions.figureOptions.selectedFigure];
      paintingStyle = PaintingStyle
          .values[widget.toolbarOptions.figureOptions.selectedFill];
    }

    return new Scribble(uuid.v4(), strokeWidth, strokeCap, color, drawPoints,
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
