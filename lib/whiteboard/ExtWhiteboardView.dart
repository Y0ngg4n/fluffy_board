import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ExtWhiteboardView extends StatefulWidget {
  
  ExtWhiteboard extWhiteboard;

  ExtWhiteboardView(this.extWhiteboard);
  
  @override
  _ExtWhiteboardViewState createState() => _ExtWhiteboardViewState();
}

class _ExtWhiteboardViewState extends State<ExtWhiteboardView> {
  @override
  Widget build(BuildContext context) {
    return InfiniteCanvasPage(SelectedTool.move);
  }
}
