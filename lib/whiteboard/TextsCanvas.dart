import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'overlays/Toolbar.dart' as Toolbar;

class TextsCanvas extends StatefulWidget {
  List<TextItem> texts;
  Offset offset;
  Offset sessionOffset;
  Toolbar.ToolbarOptions toolbarOptions;

  TextsCanvas(
      {required this.texts, required this.offset, required this.sessionOffset, required this.toolbarOptions});

  @override
  _TextsCanvasState createState() => _TextsCanvasState();
}

class _TextsCanvasState extends State<TextsCanvas> {
  @override
  Widget build(BuildContext context) {
    // TODO: Fix moving
    List<Widget> texts = [];
    for (TextItem textItem in widget.texts) {
      if(!textItem.editing) continue;
      TextEditingController textEditingController = new TextEditingController();
      textEditingController.text = textItem.text;
      textItem.strokeWidth =  widget.toolbarOptions.textOptions.strokeWidth;
      textItem.color = widget.toolbarOptions.textOptions.colorPresets[widget.toolbarOptions.textOptions.currentColor];
      texts.add(Positioned(
        child: TextField(
          controller: textEditingController,
          style: TextStyle(
            fontSize: widget.toolbarOptions.textOptions.strokeWidth,
            color: widget.toolbarOptions.textOptions.colorPresets[widget.toolbarOptions.textOptions.currentColor]
          ),
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: "Text"),
          onChanged: (value) {
            textItem.text = value;
          },
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
        width: 500,
        height: ScreenUtils.getScreenHeight(context) - textItem.offset.dy,
        top: textItem.offset.dy + widget.offset.dy,
        left: textItem.offset.dx + widget.offset.dx,
      ));
    }

    return Container(
      child: Stack(
        children: texts,
      ),
    );
  }
}
