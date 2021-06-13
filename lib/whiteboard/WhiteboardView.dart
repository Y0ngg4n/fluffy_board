import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/EraserToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/HighlighterToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'overlays/Toolbar.dart' as Toolbar;

class WhiteboardView extends StatefulWidget {
  Whiteboard whiteboard;

  WhiteboardView(this.whiteboard);

  @override
  _WhiteboardViewState createState() => _WhiteboardViewState();
}

class _WhiteboardViewState extends State<WhiteboardView> {
  Toolbar.ToolbarOptions toolbarOptions = new Toolbar.ToolbarOptions(
      Toolbar.SelectedTool.move,
      new PencilOptions(SelectedPencilColorToolbar.ColorPreset1),
      new HighlighterOptions(SelectedHighlighterColorToolbar.ColorPreset1),
      new StraightLineOptions(SelectedStraightLineColorToolbar.ColorPreset1, SelectedStraightLineCapToolbar.Normal),
      new EraserOptions(),
      new FigureOptions(SelectedFigureColorToolbar.ColorPreset1, SelectedFigureTypeToolbar.rect, PaintingStyle.stroke),
      false);
  ZoomOptions zoomOptions = new ZoomOptions(1);

  @override
  void initState() {
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => _createToolbars(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text(widget.whiteboard.name),
    );
    return Scaffold(
        appBar: (appBar),
        body: Stack(children: [
          InfiniteCanvasPage(
            toolbarOptions: toolbarOptions,
            zoomOptions: zoomOptions,
            appBarHeight: appBar.preferredSize.height,
            onChangedZoomOptions: (zoomOptions) {
              setState(() {
                this.zoomOptions = zoomOptions;
              });
            },
          ),
          Toolbar.Toolbar(
            toolbarOptions: toolbarOptions,
            onChangedToolbarOptions: (toolBarOptions) {
              setState(() {
                this.toolbarOptions = toolBarOptions;
              });
            },
          ),
          ZoomView(
            zoomOptions: zoomOptions,
            onChangedZoomOptions: (zoomOptions) {
              setState(() {
                this.zoomOptions = zoomOptions;
              });
            },
          )
        ]));
  }
}
