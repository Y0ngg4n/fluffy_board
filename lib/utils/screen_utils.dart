import 'dart:math';

import 'package:fluffy_board/whiteboard/canvas_custom_painter.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/draw_point.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:simplify/simplify.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vector_math/vector_math.dart' as vectormath;

class ScreenUtils {
  static final LocalStorage settingsStorage = new LocalStorage('settings');

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

  static bool inRect(Rect rect, Offset location) {
    if (location.dx >= rect.topLeft.dx &&
        location.dx <= rect.topRight.dx &&
        location.dy >= rect.topCenter.dy &&
        location.dy <= rect.bottomCenter.dy)
      return true;
    else
      return false;
  }

  static bool checkScribbleIfNotInScreen(
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

  static double isLeft(Offset p0, Offset p1, Offset p2) {
    return ((p1.dx - p0.dx) * (p2.dy - p0.dy) -
            (p2.dx - p0.dx) * (p1.dy - p0.dy))
        .toDouble();
  }

  static bool pointInRectangle(
      Offset X, Offset Y, Offset Z, Offset W, Offset checkPoint) {
    return (isLeft(X, Y, checkPoint) > 0 &&
        isLeft(Y, Z, checkPoint) > 0 &&
        isLeft(Z, W, checkPoint) > 0 &&
        isLeft(W, X, checkPoint) > 0);
  }

  static Offset calculateRotatedTopLeftCTopLeft(
      Offset offset, Offset middlePoint, double rotation) {
    double xRotatedTopLeft = ((offset.dx - middlePoint.dx) * cos(rotation)) -
        ((middlePoint.dy - offset.dy) * sin(rotation)) +
        middlePoint.dx;
    double yRotatedTopLeft = middlePoint.dy -
        ((middlePoint.dy - offset.dy) * cos(rotation)) +
        ((offset.dx - middlePoint.dx) * sin(rotation));
    return new Offset(xRotatedTopLeft, yRotatedTopLeft);
  }

  static Offset calculateRotatedCBottomLeft(
      Offset offset, Offset middlePoint, rotation) {
    double xRotated = ((offset.dx - middlePoint.dx) * cos(rotation)) -
        ((offset.dy - middlePoint.dy) * sin(rotation)) +
        middlePoint.dx;
    double yRotated = ((offset.dx - middlePoint.dx) * sin(rotation)) +
        ((offset.dy - middlePoint.dy) * cos(rotation)) +
        middlePoint.dy;
    return new Offset(xRotated, yRotated);
  }

  static Offset getUploadMiddlePointWithOffset(
      Upload currentUpload, Offset calculatedOffset) {
    return new Offset(
        currentUpload.offset.dx +
            calculatedOffset.dx +
            currentUpload.image!.width / 2,
        currentUpload.offset.dy +
            calculatedOffset.dy +
            currentUpload.image!.height / 2);
  }

  static Offset getUploadMiddlePoint(Upload currentUpload) {
    return new Offset(currentUpload.offset.dx + currentUpload.image!.width / 2,
        currentUpload.offset.dy + currentUpload.image!.height / 2);
  }

  static Offset getTextItemMiddlePoint(TextItem textItem, TextPainter textPainter) {
    return new Offset(textItem.offset.dx + textPainter.width / 2,
        textItem.offset.dy + textPainter.height / 2);
  }

  static bool checkUploadIfNotInScreen(
      Upload currentUpload,
      Offset calculatedOffset,
      double screenWidth,
      double screenHeight,
      double scale) {
    if (currentUpload.image == null) return false;

    if (currentUpload.rotation == 0) {
      return (currentUpload.offset.dx + calculatedOffset.dx < 0 &&
                  currentUpload.offset.dx +
                          currentUpload.image!.width +
                          calculatedOffset.dx <
                      0)
              // Check Right
              ||
              (currentUpload.offset.dx +
                          currentUpload.image!.width +
                          calculatedOffset.dx >
                      (screenWidth / scale) &&
                  currentUpload.offset.dx + calculatedOffset.dx >
                      (screenWidth / scale))
              // Check Top
              ||
              (currentUpload.offset.dy + calculatedOffset.dy < 0 &&
                  currentUpload.offset.dy +
                          currentUpload.image!.height +
                          calculatedOffset.dy <
                      0)
              //    Check Bottom
              ||
              (currentUpload.offset.dy +
                          currentUpload.image!.height +
                          calculatedOffset.dy >
                      (screenHeight) / scale &&
                  currentUpload.offset.dy + calculatedOffset.dy >
                      (screenHeight) / scale)
          ? true
          : false;
    } else {
      Offset middlePoint =
          getUploadMiddlePointWithOffset(currentUpload, calculatedOffset);

      Offset leftTopOffset = new Offset(
          currentUpload.offset.dx + calculatedOffset.dx,
          currentUpload.offset.dy + calculatedOffset.dy);
      Offset rightTopOffset = new Offset(
          currentUpload.offset.dx + calculatedOffset.dx + currentUpload.image!.width,
          currentUpload.offset.dy + calculatedOffset.dy);
      Offset rightBottomOffset = new Offset(
          currentUpload.offset.dx + calculatedOffset.dx + currentUpload.image!.width,
          currentUpload.offset.dy + calculatedOffset.dy + currentUpload.image!.height);
      Offset leftBottomOffset = new Offset(currentUpload.offset.dx + calculatedOffset.dx ,
          currentUpload.offset.dy + calculatedOffset.dy + currentUpload.image!.height);

      Offset rotatedLeftTopOffset = calculateRotatedCBottomLeft(leftTopOffset,
          middlePoint, vectormath.radians(currentUpload.rotation));
      Offset rotatedRightTopOffset = calculateRotatedCBottomLeft(rightTopOffset,
          middlePoint, vectormath.radians(currentUpload.rotation));
      Offset rotatedRightBottomOffset = calculateRotatedCBottomLeft(
          rightBottomOffset,
          middlePoint,
          vectormath.radians(currentUpload.rotation));
      Offset rotatedLeftBottomOffset = calculateRotatedCBottomLeft(
          leftBottomOffset,
          middlePoint,
          vectormath.radians(currentUpload.rotation));

      bool notInScreen = (
          // Check left
          rotatedLeftTopOffset.dx < 0 &&
                      rotatedRightTopOffset.dx < 0 &&
                      rotatedLeftBottomOffset.dx < 0 &&
                      rotatedRightBottomOffset.dx < 0
                  // Check Right
                  ||
                  (rotatedLeftTopOffset.dx >
                          (screenWidth / scale) &&
                      rotatedRightTopOffset.dx >
                          (screenWidth / scale) &&
                      rotatedLeftBottomOffset.dx >
                          (screenWidth / scale) &&
                      rotatedRightBottomOffset.dx >
                          (screenWidth / scale))
                  // // Check Top
                  ||
                  (rotatedLeftTopOffset.dy  < 0&&
                      rotatedRightTopOffset.dy  < 0 &&
                      rotatedLeftBottomOffset.dy < 0 &&
                      rotatedRightBottomOffset.dy < 0)
                  // //    Check Bottom
                  ||
                  (rotatedLeftTopOffset.dy >
                          (screenHeight / scale) &&
                      rotatedRightTopOffset.dy >
                          (screenHeight / scale) &&
                      rotatedLeftBottomOffset.dy >
                          (screenHeight / scale) &&
                      rotatedRightBottomOffset.dy >
                          (screenHeight / scale))
              ? true
              : false);
      return notInScreen;
    }
  }

  static bool checkIfInUploadRect(
      Upload currentUpload, double scale, Offset location) {
    if (currentUpload.image == null) return false;

    if (currentUpload.rotation == 0) {
      if (location.dx >= currentUpload.offset.dx &&
          location.dx <= currentUpload.offset.dx + currentUpload.image!.width &&
          location.dy >= currentUpload.offset.dy &&
          location.dy <= currentUpload.offset.dy + currentUpload.image!.height)
        return true;
      else
        return false;
    } else {
      Offset middlePoint = getUploadMiddlePoint(currentUpload);

      Offset invertRotatedLocation = calculateRotatedCBottomLeft(
          location, middlePoint, vectormath.radians(-currentUpload.rotation));

      bool notInScreen = (
          // Check if inverted rotated Point is in not rotated Image rect
          invertRotatedLocation.dx >= currentUpload.offset.dx &&
                  invertRotatedLocation.dx <=
                      currentUpload.offset.dx + currentUpload.image!.width &&
                  invertRotatedLocation.dy >= currentUpload.offset.dy &&
                  invertRotatedLocation.dy <=
                      currentUpload.offset.dy + currentUpload.image!.height
              ? true
              : false);
      return notInScreen;
    }
  }

  static bool checkIfInTextPainterRect(
      TextPainter textPainter, TextItem textItem, double scale, Offset location) {
    if (textItem.rotation == 0) {
      if (location.dx >= textItem.offset.dx &&
          location.dx <= textItem.offset.dx + textPainter.width &&
          location.dy >= textItem.offset.dy &&
          location.dy <= textItem.offset.dy + textPainter.height)
        return true;
      else
        return false;
    } else {
      Offset middlePoint = getTextItemMiddlePoint(textItem, textPainter);

      Offset invertRotatedLocation = calculateRotatedCBottomLeft(
          location, middlePoint, vectormath.radians(-textItem.rotation));

      bool notInScreen = (
          // Check if inverted rotated Point is in not rotated Image rect
          invertRotatedLocation.dx >= textItem.offset.dx &&
              invertRotatedLocation.dx <=
                  textItem.offset.dx + textPainter.width &&
              invertRotatedLocation.dy >= textItem.offset.dy &&
              invertRotatedLocation.dy <=
                  textItem.offset.dy + textPainter.height
              ? true
              : false);
      return notInScreen;
    }
  }

  static bool checkTextPainterIfNotInScreen(
      TextPainter currentTextPainter,
      Offset offset,
      Offset calculatedOffset,
      double screenWidth,
      double screenHeight,
      double scale) {
    return (offset.dx + calculatedOffset.dx < 0 &&
                offset.dx + currentTextPainter.width + calculatedOffset.dx < 0)
            // Check Right
            ||
            (offset.dx + currentTextPainter.width + calculatedOffset.dx >
                    (screenWidth / scale) &&
                offset.dx + calculatedOffset.dx > (screenWidth / scale))
            // Check Top
            ||
            (offset.dy + calculatedOffset.dy < 0 &&
                offset.dy + currentTextPainter.height + calculatedOffset.dy < 0)
            //    Check Bottom
            ||
            (offset.dy + currentTextPainter.height + calculatedOffset.dy >
                    (screenHeight) / scale &&
                offset.dy + calculatedOffset.dy > (screenHeight) / scale)
        ? true
        : false;
  }

  static TextPainter getTextPainter(TextItem textItem) {
    final textStyle = TextStyle(
      color: textItem.color,
      fontSize: textItem.strokeWidth,
    );

    final textSpan = TextSpan(
      text: textItem.text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 500,
    );
    return textPainter;
  }

  static calculateScribbleBounds(Scribble newScribble) {
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

    // Offset middlePoint = calculateMiddlePoint(newScribble.leftExtremity, newScribble.rightExtremity, newScribble.topExtremity, newScribble.bottomExtremity);
    // Offset topLeftRotatedPoint = calculateRotatedPoint(middlePoint, new Offset(newScribble.leftExtremity, newScribble.topExtremity), newScribble.rotation);
    // Offset bottomRightRotatedPoint = calculateRotatedPoint(middlePoint, new Offset(newScribble.rightExtremity, newScribble.bottomExtremity), newScribble.rotation);
    // newScribble.leftExtremity = topLeftRotatedPoint.dx;
    // print(newScribble.leftExtremity);
    // newScribble.topExtremity = topLeftRotatedPoint.dy;
    // newScribble.rightExtremity = bottomRightRotatedPoint.dx;
    // newScribble.bottomExtremity = bottomRightRotatedPoint.dy;
  }

  static calculateMiddlePoint(double leftExtremity, double rightExtremity,
      double topExtremity, double bottomExtremity) {
    return new Offset((rightExtremity - leftExtremity) / 2,
        (bottomExtremity - topExtremity) / 2);
  }

  static calculateRotatedPoint(
      Offset middlePoint, Offset point, double rotation) {
    double newX = middlePoint.dx +
        (point.dx - middlePoint.dx) * cos(rotation) -
        (point.dy - middlePoint.dy) * sin(rotation);
    // y′=10+(x−5)sin(φ)+(y−10)cos(φ)
    double newY = middlePoint.dy +
        (point.dx - middlePoint.dx) * sin(rotation) +
        (point.dy - middlePoint.dy) * cos(rotation);
    return Offset(newX, newY);
  }

  static bakeScribble(Scribble scribble, double scale) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);
    // Can be increased if to pixelated scribbles
    double scribbleWidth = (scribble.rightExtremity - scribble.leftExtremity);
    double scribbleHeight = (scribble.bottomExtremity - scribble.topExtremity);
    PainterUtils.paintScribble(
        scribble,
        canvas,
        scale,
        new Offset(-scribble.leftExtremity + scribble.strokeWidth,
            -scribble.topExtremity + scribble.strokeWidth),
        false,
        null);
    // Finally render the image, this can take about 8 to 25 milliseconds.
    var picture = recorder.endRecording();
    // TODO: Check if cuts are right and make less pixelated
    double imageWidth = getBakeImageWidth(scribbleWidth, scribble, scale);
    double imageHeight = getBakeImageHeight(scribbleHeight, scribble, scale);
    try {
      var newImage =
          await picture.toImage((imageWidth).ceil(), (imageHeight).ceil());
      scribble.backedScribble = newImage;
    } catch (e) {
      print(e);
      print(imageWidth);
      print(imageHeight);
    }
  }

  static getBakeImageWidth(
      double scribbleWidth, Scribble scribble, double scale) {
    return ((scribbleWidth + scribble.strokeWidth * 2) *
        (scale < 1 ? (1 + (1 - scale)) : scale));
  }

  static getBakeImageHeight(
      double scribbleHeight, Scribble scribble, double scale) {
    return ((scribbleHeight + scribble.strokeWidth * 2) *
        (scale < 1 ? (1 + (1 - scale)) : scale));
  }

  static simplifyScribble(Scribble scribble) {
    if (settingsStorage.getItem("points-simplify") ?? true != false) {
      List<Point> points =
          scribble.points.map((e) => Point(e.dx, e.dy)).toList();
      points = simplify(points, highestQuality: true);
      scribble.points =
          points.map((e) => DrawPoint(e.x.toDouble(), e.y.toDouble())).toList();
    }
  }
}
