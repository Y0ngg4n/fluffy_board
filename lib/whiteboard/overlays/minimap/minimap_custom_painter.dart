import 'package:fluffy_board/utils/export_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MinimapCustomPainter extends CustomPainter {
  ExportPNG? exportPNG;
  Offset screenSize;
  Offset offset;
  double scale;
  double imageScale;

  //define canvas background color
  final Paint background = new Paint()..color = Colors.white;

  final Paint selectionPaint = new Paint()
    ..color = Colors.blue
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  MinimapCustomPainter(
      {required this.exportPNG,
      required this.screenSize,
      required this.offset,
      required this.scale,
      required this.imageScale});

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);
    canvas.save();

    if (exportPNG != null) {
      double leftBoundsOffset = exportPNG!.bounds.left;
      double topBoundsOffset = exportPNG!.bounds.top;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Colors.white);
      // canvas.drawImage(exportPNG!.image, Offset(0,0), Paint());
      paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(0, 0, size.width, size.height),
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          image: exportPNG!.image);

      double imageWidthScale = exportPNG!.image.width / size.width;
      double imageHeightScale = exportPNG!.image.height / size.height;
      Offset imageNotFitOffset = Offset.zero;
      double rectWidth = screenSize.dx / imageWidthScale;
      double rectHeight = screenSize.dy / imageHeightScale;
      double imageNotFitWidthScale = 1;
      double imageNotFitHeightScale = 1;
      bool imageWidthNotFit = false;
      bool imageHeightNotFit = false;

      // TODO: Fix too fast scrolling when image is not fit
      // TODO: Analyse error with missing rendering on bottom of minimap
      if (exportPNG!.image.width < screenSize.dx || rectWidth >= size.width) {
        imageWidthNotFit = true;
        double screenAspectRatio = screenSize.dx / screenSize.dy;
        rectWidth = screenAspectRatio * rectHeight;
        imageNotFitWidthScale = screenSize.dx / size.width;
        imageNotFitOffset = new Offset(
            imageNotFitOffset.dx + size.width / 2 - rectWidth / 2,
            imageNotFitOffset.dy);
      }
      if (exportPNG!.image.height < screenSize.dy || rectWidth >= size.height) {
        imageHeightNotFit = true;
        double screenAspectRatio = screenSize.dy / screenSize.dx;
        rectHeight = screenAspectRatio * rectWidth;
        imageNotFitHeightScale = screenSize.dy / size.height;
        imageNotFitOffset = new Offset(imageNotFitOffset.dx,
            imageNotFitOffset.dy + size.height / 2 - rectWidth / 2);
      }
      double verticalScaleDown = exportPNG!.image.height / size.height;
      double horizontalScaleDown = exportPNG!.image.width / size.width;
      double verticalDifference =
          (exportPNG!.bounds.bottom - exportPNG!.bounds.top).abs() /
              verticalScaleDown /
              2;
      double horizontalDifference =
          (exportPNG!.bounds.right - exportPNG!.bounds.left).abs() /
              horizontalScaleDown /
              2;
      Offset compensationOffset = new Offset(
          -horizontalDifference + size.width / 2,
          -verticalDifference + size.height / 2);

      Rect pointerRect = Rect.fromPoints(
          (new Offset(0, 0) -
                      new Offset(
                          offset.dx /
                              (imageWidthNotFit
                                  ? imageNotFitWidthScale
                                  : imageWidthScale),
                          offset.dy / (imageHeightNotFit
                              ? imageNotFitHeightScale
                              : imageHeightScale))) /
                  scale +
              imageNotFitOffset +
              compensationOffset,
          (new Offset(rectWidth, rectHeight) -
                      new Offset(
                          offset.dx /
                              (imageWidthNotFit
                                  ? imageNotFitWidthScale
                                  : imageWidthScale),
                          offset.dy / (imageHeightNotFit
                              ? imageNotFitHeightScale
                              : imageHeightScale))) /
                  scale +
              imageNotFitOffset +
              compensationOffset);

      canvas.drawRect(pointerRect, selectionPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
