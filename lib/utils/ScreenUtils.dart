import 'package:fluffy_board/whiteboard/CanvasCustomPainter.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ScreenUtils {
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

  static bool checkUploadIfNotInScreen(
      Upload currentUpload,
      Offset calculatedOffset,
      double screenWidth,
      double screenHeight,
      double scale) {
    if (currentUpload.image == null) return false;

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
  }

  static bakeScribble(Scribble scribble, double scale, Offset offset) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);
    double scribbleWidth = (scribble.rightExtremity - scribble.leftExtremity);
    double scribbleHeight = (scribble.bottomExtremity - scribble.topExtremity);
    canvas.save();
    PainterUtils.paintScribble(scribble, canvas, scale,
        new Offset(-scribble.leftExtremity + scribble.strokeWidth, -scribble.topExtremity + scribble.strokeWidth));
    // Finally render the image, this can take about 8 to 25 milliseconds.
    var picture = recorder.endRecording();
    var newImage = await picture.toImage(
      ((scribbleWidth * scale) + scribble.strokeWidth * 2).ceil(),
      ((scribbleHeight * scale) + scribble.strokeWidth * 2).ceil(),
    );
    scribble.backedScribble = newImage;
  }
}
