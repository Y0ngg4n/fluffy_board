import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'overlays/Toolbar.dart';

class WhiteboardView extends StatefulWidget {
  Whiteboard whiteboard;

  WhiteboardView(this.whiteboard);

  @override
  _WhiteboardViewState createState() => _WhiteboardViewState();
}

class _WhiteboardViewState extends State<WhiteboardView> {
  SelectedTool selectedTool = SelectedTool.move;

  @override
  void initState() {
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => _createToolbars(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (AppBar(
          title: Text("Whiteboard"),
        )),
        body: Stack(children: [
          InfiniteCanvasPage(
            selectedTool,
          ),
          Toolbar(
              onSelectedTool: (selectedTool) => {
                    setState(() {
                      this.selectedTool = selectedTool;
                    })
                  }),
        ]));
  }
}
