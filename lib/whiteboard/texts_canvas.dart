import 'dart:convert';

import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/json_encodable.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'Websocket/websocket_manager_send.dart';
import 'Websocket/websocket-types/websocket_types.dart';
import 'overlays/toolbar.dart' as Toolbar;
import 'dart:math';
import 'package:vector_math/vector_math.dart';

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
        child: Transform.rotate(
          angle: radians(textItem.rotation),
          child: TextField(
            controller: textEditingController,
            style: TextStyle(fontSize: strokeWidth, color: color),
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Text"),
            minLines: 3,
            onChanged: (value) {
              textItem.text = value;
              WebsocketSend.sendUpdateTextItem(textItem, widget.websocketConnection);
            },
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
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


}
