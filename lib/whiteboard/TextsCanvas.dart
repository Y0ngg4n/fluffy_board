import 'dart:convert';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'Websocket/WebsocketTypes.dart';
import 'overlays/Toolbar.dart' as Toolbar;

class TextsCanvas extends StatefulWidget {
  List<TextItem> texts;
  Offset offset;
  Offset sessionOffset;
  Toolbar.ToolbarOptions toolbarOptions;
  WebsocketConnection? websocketConnection;

  TextsCanvas(
      {required this.texts,
      required this.offset,
      required this.sessionOffset,
      required this.toolbarOptions,
      required this.websocketConnection});

  @override
  _TextsCanvasState createState() => _TextsCanvasState();
}

class _TextsCanvasState extends State<TextsCanvas> {
  @override
  Widget build(BuildContext context) {
    // TODO: Fix moving
    List<Widget> texts = [];
    for (TextItem textItem in widget.texts) {
      if (!textItem.editing) continue;
      TextEditingController textEditingController = new TextEditingController();
      textEditingController.text = textItem.text;
      double strokeWidth;
      Color color;
      if (widget.toolbarOptions.settingsSelectedTextItem == null) {
        textItem.strokeWidth = widget.toolbarOptions.textOptions.strokeWidth;
        strokeWidth = widget.toolbarOptions.textOptions.strokeWidth;
        textItem.color = widget.toolbarOptions.textOptions
            .colorPresets[widget.toolbarOptions.textOptions.currentColor];
        color = widget.toolbarOptions.textOptions
            .colorPresets[widget.toolbarOptions.textOptions.currentColor];
      } else {
        strokeWidth =
            widget.toolbarOptions.settingsSelectedTextItem!.strokeWidth;
        color = widget.toolbarOptions.settingsSelectedTextItem!.color;
      }

      texts.add(Positioned(
        child: TextField(
          controller: textEditingController,
          style: TextStyle(fontSize: strokeWidth, color: color),
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: "Text"),
          minLines: 3,
          onChanged: (value) {
            textItem.text = value;
            sendUpdateTextItem(textItem);
          },
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
        width: textItem.maxWidth.toDouble(),
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

  sendUpdateTextItem(TextItem textItem) {
    String data = jsonEncode(WSTextItemUpdate(
        textItem.uuid,
        textItem.strokeWidth,
        textItem.maxWidth,
        textItem.maxHeight,
        textItem.color.toHex(),
        textItem.text,
        textItem.offset.dx,
        textItem.offset.dy));
    if (widget.websocketConnection != null)
      widget.websocketConnection!.channel.add("textitem-update#" + data);
  }
}
