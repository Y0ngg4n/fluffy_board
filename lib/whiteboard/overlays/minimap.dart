import 'dart:async';

import 'package:fluffy_board/utils/export_utils.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar.dart' as Toolbar;
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'minimap/minimap_custom_painter.dart';

typedef OnChangedOffset<T> = Function(Offset);

class MinimapView extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final OnChangedOffset onChangedOffset;
  final Offset offset;
  final String toolbarLocation;
  final List<Scribble> scribbles;
  final List<Upload> uploads;
  final List<TextItem> texts;
  final ui.Offset screenSize;
  final double scale;

  MinimapView(
      {required this.toolbarOptions,
      required this.onChangedOffset,
      required this.offset,
      required this.toolbarLocation,
      required this.scribbles,
      required this.uploads,
      required this.texts,
      required this.screenSize,
      required this.scale,
      });

  @override
  _MinimapViewState createState() => _MinimapViewState();
}

class _MinimapViewState extends State<MinimapView> {
  final double zoomFactor = 0.1;
  ExportPNG? exportPNG;
  final double imageScale = 6;
  late Timer generateImageTimer;

  @override
  void initState() {
    generateImage();
    generateImageTimer = Timer.periodic(
        Duration(seconds: 60), (timer) => generateImage());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    generateImageTimer.cancel();
  }

  void generateImage(){
    ExportUtils.getExportPNG(
        widget.scribbles,
        widget.uploads,
        widget.texts,
        widget.toolbarOptions,
        widget.screenSize,
        widget.offset,
        widget.scale)
        .then((value) => setState(() {
      this.exportPNG = value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtils.getScreenWidth(context);
    double screenHeight = ScreenUtils.getScreenHeight(context);
    double width = screenWidth / imageScale;
    double height = screenHeight / imageScale;

    MainAxisAlignment mainAxisAlignmentRow;

    switch (widget.toolbarLocation) {
      case "right":
        mainAxisAlignmentRow = MainAxisAlignment.start;
        break;
      default:
        mainAxisAlignmentRow = MainAxisAlignment.end;
        break;
    }

    if (widget.toolbarOptions.colorPickerOpen) return Container();

    return Row(
      mainAxisAlignment: mainAxisAlignmentRow,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                width: width,
                height: height,
                child: Card(
                  child: GestureDetector(
                    onScaleStart: (event) => onScaleStart(event, width, height, screenWidth, screenHeight),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          isComplex: true,
                          willChange: true,
                          painter: MinimapCustomPainter(
                              exportPNG: exportPNG,
                              screenSize: widget.screenSize,
                              scale: widget.scale,
                              imageScale: imageScale,
                              offset: widget.offset),
                        );
                      },
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }

  void onScaleStart(ScaleStartDetails details, double width, double height, double screenWidth, double screenHeight){
    double imageWidthScale = exportPNG!.image.width / width;
    double imageHeightScale = exportPNG!.image.height / height;

    double rectWidth = screenWidth / imageWidthScale;
    double rectHeight = screenHeight / imageHeightScale;

    Offset offset = new Offset(
        ((details.localFocalPoint.dx - (rectWidth / 2))) * imageWidthScale,
        ((details.localFocalPoint.dy - (rectHeight / 2))) * imageHeightScale
    );

    print(offset);

    widget.onChangedOffset(-offset);
  }
}
