import 'dart:math';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/background_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/figure_toolbar.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vector_math/vector_math.dart' as vectormath;

import 'appbar/connected_users.dart';
import 'overlays/toolbar.dart' as Toolbar;
import 'whiteboard-data/scribble.dart';

class CanvasCustomPainter extends CustomPainter {
  Toolbar.ToolbarOptions toolbarOptions;
  List<Scribble> scribbles;
  Offset offset;
  double scale;
  double cursorRadius;
  Offset cursorPosition;
  Offset screenSize;
  List<Upload> uploads;
  List<TextItem> texts;
  bool multiSelect;
  bool multiSelectMove;
  Offset multiSelectStartPosition;
  Offset multiSelectStopPosition;
  Offset? hoverPosition;
  Set<ConnectedUser> connectedUsers;

  CanvasCustomPainter(
      {required this.scribbles,
      required this.offset,
      required this.scale,
      required this.cursorRadius,
      required this.cursorPosition,
      required this.toolbarOptions,
      required this.screenSize,
      required this.uploads,
      required this.texts,
      required this.multiSelect,
      required this.multiSelectMove,
      required this.multiSelectStartPosition,
      required this.multiSelectStopPosition,
      required this.hoverPosition,
      required this.connectedUsers});

  //define canvas background color
  Paint background = Paint()..color = Colors.white;

  // Draw Multiselect
  Paint multiselectPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Color.fromARGB(50, 31, 133, 222)
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  // Draw Cursor radius
  Paint cursorPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Colors.blueGrey
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);
    canvas.scale(scale);

    PainterUtils.paintBackground(
        canvas, toolbarOptions, screenSize, offset, scale);
    PainterUtils.paintUploads(
        canvas, uploads, screenSize, scale, offset, true, toolbarOptions);
    PainterUtils.paintTextItems(
        canvas, texts, offset, screenSize, scale, true, toolbarOptions);
    PainterUtils.paintScribbles(
        canvas, scribbles, offset, screenSize, scale, true, toolbarOptions);

    PainterUtils.paintCursors(
        canvas, connectedUsers, offset, screenSize, scale);

    if (multiSelect && !multiSelectMove) {
      canvas.drawRect(
          Rect.fromPoints(multiSelectStartPosition + offset,
              multiSelectStopPosition + offset),
          multiselectPaint);
    }

    canvas.drawCircle(cursorPosition, cursorRadius, cursorPaint);
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}

class PainterUtils {
  static final LocalStorage settingsStorage = new LocalStorage('settings');

  // Draw Multiselect
  static final Paint selectPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Color.fromARGB(50, 31, 133, 222)
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  static paintScribbles(
      Canvas canvas,
      List<Scribble> scribbles,
      Offset offset,
      Offset screenSize,
      double scale,
      bool checkView,
      Toolbar.ToolbarOptions? toolbarOptions) {
    //a single line is defined as a series of points followed by a null at the end
    for (Scribble scribble in scribbles) {
      if (checkView &&
          ScreenUtils.checkScribbleIfNotInScreen(
              scribble, offset, screenSize.dx, screenSize.dy, scale)) {
        continue;
      }
      PainterUtils.paintScribble(
          scribble, canvas, scale, offset, checkView, toolbarOptions);
    }
  }

  static paintScribble(Scribble scribble, Canvas canvas, double scale,
      Offset offset, bool checkView,
      [Toolbar.ToolbarOptions? toolbarOptions]) {
    Paint drawingPaint = Paint()
      ..strokeCap = scribble.strokeCap
      ..isAntiAlias = true
      ..color = scribble.color
      ..strokeWidth = scribble.strokeWidth;

    Paint figurePaint = drawingPaint..style = scribble.paintingStyle;
    // canvas.save();
    // canvas.translate(((scribble.rightExtremity - scribble.leftExtremity) / 2) + offset.dx,
    //     ((scribble.bottomExtremity - scribble.topExtremity) / 2) + offset.dy);
    // canvas.rotate(vectormath.radians(scribble.rotation));

    if (scribble.backedScribble == null ||
        !(settingsStorage.getItem("points-to-image") ?? true)) {
      switch (scribble.selectedFigureTypeToolbar) {
        case SelectedFigureTypeToolbar.rect:
          canvas.drawRect(
              Rect.fromLTWH(
                  scribble.points.first.dx + offset.dx,
                  scribble.points.first.dy + offset.dy,
                  scribble.points.last.dx - scribble.points.first.dx,
                  scribble.points.last.dy - scribble.points.first.dy),
              figurePaint);
          break;
        case SelectedFigureTypeToolbar.triangle:
          Path path = new Path();
          path.moveTo((scribble.points.first + offset).dx,
              (scribble.points.first + offset).dy);
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
          double deltaX = scribble.points.last.dx - scribble.points.first.dx;
          double deltaY = scribble.points.last.dy - scribble.points.first.dy;
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
            //       PointMode.points, [scribble.points[x] + offset], drawingPaint);
            // }
          }
          break;
      }
      if (toolbarOptions != null &&
          toolbarOptions.settingsSelectedScribble == scribble) {
        Offset leftTopOffset = new Offset(
                scribble.leftExtremity - scribble.strokeWidth * 2,
                scribble.topExtremity - scribble.strokeWidth * 2) +
            offset;
        Offset rigthBottomOffset = new Offset(
                scribble.rightExtremity + scribble.strokeWidth * 2,
                scribble.bottomExtremity + scribble.strokeWidth * 2) +
            offset;
        canvas.drawRect(
            Rect.fromPoints(leftTopOffset, rigthBottomOffset), selectPaint);
      }
    } else {
      Paint paint = new Paint();
      paint.color = Colors.green;
      Offset leftTopOffset = new Offset(
              scribble.leftExtremity - scribble.strokeWidth * 2,
              scribble.topExtremity - scribble.strokeWidth * 2) +
          offset;
      Offset rightBottomOffset = new Offset(
          scribble.leftExtremity + scribble.backedScribble!.width + offset.dx,
          scribble.topExtremity + scribble.backedScribble!.height + offset.dy);
      paintImage(
        canvas: canvas,
        rect: Rect.fromPoints(
          leftTopOffset,
          rightBottomOffset,
        ),
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        image: scribble.backedScribble!,
        // Can be increased if to pixelated
        // scale: 1
      );
      if (toolbarOptions != null &&
          toolbarOptions.settingsSelectedScribble == scribble) {
        canvas.drawRect(
            Rect.fromPoints(leftTopOffset, rightBottomOffset), selectPaint);
      }
    }
    // canvas.restore();
  }

  static paintBackground(Canvas canvas, Toolbar.ToolbarOptions toolbarOptions,
      Offset screenSize, Offset offset, double scale) {
    // Draw Background
    Paint backgroundPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.blueGrey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // TODO: Fix Scaled Scrolling
    // Draw Background
    if (SelectedBackgroundTypeToolbar
                .values[toolbarOptions.backgroundOptions.selectedBackground] ==
            SelectedBackgroundTypeToolbar.Lines ||
        SelectedBackgroundTypeToolbar
                .values[toolbarOptions.backgroundOptions.selectedBackground] ==
            SelectedBackgroundTypeToolbar.Grid) {
      for (int i = -offset.dy.toInt().abs();
          i <
              (((screenSize.dy + offset.dy.abs()) / scale) /
                  toolbarOptions.backgroundOptions.strokeWidth);
          i++) {
        canvas.drawLine(
            new Offset(0,
                (toolbarOptions.backgroundOptions.strokeWidth * i) + offset.dy),
            new Offset(screenSize.dx / scale,
                (toolbarOptions.backgroundOptions.strokeWidth * i) + offset.dy),
            backgroundPaint);
      }
    }
    if (SelectedBackgroundTypeToolbar
            .values[toolbarOptions.backgroundOptions.selectedBackground] ==
        SelectedBackgroundTypeToolbar.Grid) {
      for (int i = -offset.dx.toInt().abs();
          i <
              (((screenSize.dx + offset.dx.abs()) / scale) /
                  toolbarOptions.backgroundOptions.strokeWidth);
          i++) {
        canvas.drawLine(
            new Offset(
                (toolbarOptions.backgroundOptions.strokeWidth * i) + offset.dx,
                0),
            new Offset(
              (toolbarOptions.backgroundOptions.strokeWidth * i) + offset.dx,
              screenSize.dy / scale,
            ),
            backgroundPaint);
      }
    }
  }

  static paintUploads(Canvas canvas, List<Upload> uploads, Offset screenSize,
      double scale, Offset offset, bool checkView,
      [Toolbar.ToolbarOptions? toolbarOptions]) {
    // Images

    for (Upload upload in uploads) {
      if (ScreenUtils.checkUploadIfNotInScreen(
              upload, offset, screenSize.dx, screenSize.dy, scale) &&
          checkView) continue;
      if (upload.image == null) continue;
      canvas.save();
      canvas.translate(upload.offset.dx + offset.dx + upload.image!.width / 2,
          upload.offset.dy + offset.dy + upload.image!.height / 2);
      canvas.rotate(vectormath.radians(upload.rotation));
      paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(
              -(upload.image!.width / 2),
              -(upload.image!.height / 2),
              (upload.image!.width).toDouble(),
              (upload.image!.height).toDouble()),
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          scale: upload.scale,
          image: upload.image!);
      if (toolbarOptions != null &&
          toolbarOptions.settingsSelectedUpload == upload &&
          upload.image != null) {
        canvas.drawRect(
            Rect.fromLTWH(
                -(upload.image!.width / 2),
                -(upload.image!.height / 2),
                (upload.image!.width).toDouble(),
                (upload.image!.height).toDouble()),
            selectPaint);
      }
      canvas.restore();
    }
  }

  static paintTextItems(Canvas canvas, List<TextItem> texts, Offset offset,
      Offset screenSize, double scale, bool checkView,
      [Toolbar.ToolbarOptions? toolbarOptions]) {
    // TextItems
    for (TextItem textItem in texts) {
      if (textItem.editing) continue;

      TextPainter textPainter = ScreenUtils.getTextPainter(textItem);
      if (ScreenUtils.checkTextPainterIfNotInScreen(textPainter,
              textItem.offset, offset, screenSize.dx, screenSize.dy, scale) &&
          checkView) continue;
      canvas.save();
      Offset newOffset = textItem.offset + offset;
      Offset middlePoint = new Offset((newOffset.dx + (textPainter.width / 2)),
          (newOffset.dy + (textPainter.height / 2)));
      canvas.drawCircle(middlePoint, 10, new Paint()..color = Colors.green);
      canvas.drawCircle(newOffset, 10, new Paint()..color = Colors.red);
      canvas.translate(middlePoint.dx, middlePoint.dy);
      canvas.rotate(vectormath.radians(textItem.rotation));
      textPainter.paint(
        canvas,
        new Offset(- (textPainter.width / 2),
            (-(textPainter.height / 2))),
      );
      if (toolbarOptions != null &&
          toolbarOptions.settingsSelectedTextItem == textItem) {
        canvas.drawRect(
            Rect.fromLTWH(
                - (textPainter.width / 2),
                -(textPainter.height / 2),
                (textPainter.width).toDouble(),
                (textPainter.height).toDouble()),
            selectPaint);
      }
      canvas.restore();
    }
  }

  static paintCursors(Canvas canvas, Set<ConnectedUser> connectedUsers,
      Offset offset, Offset screenSize, double scale) {
    if (settingsStorage.getItem("user-cursors") ?? true) {
      final icon = OwnIcons.location_arrow;
      for (ConnectedUser connectedUser in connectedUsers) {
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: connectedUser.color,
            fontSize: 16,
            fontFamily: icon.fontFamily,
            package: icon
                .fontPackage, // This line is mandatory for external icon packs
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, connectedUser.cursorOffset);
      }
    }
  }
}
