import 'dart:convert';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../DrawPoint.dart';
import '../../../WhiteboardView.dart';
import '../../Toolbar.dart' as Toolbar;

class TextItemSettings extends StatefulWidget {
  TextItem? selectedTextItem;
  List<TextItem> texts;
  OnTextItemsChange onTextItemsChange;
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  WebsocketConnection? websocketConnection;

  TextItemSettings(
      {required this.selectedTextItem,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.texts,
      required this.onTextItemsChange,
      required this.websocketConnection});

  @override
  _TextItemSettingsState createState() => _TextItemSettingsState();
}

class _TextItemSettingsState extends State<TextItemSettings> {
  @override
  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: -1,
                child: Slider.adaptive(
                  value: widget.selectedTextItem!.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.selectedTextItem!.strokeWidth = value;
                      widget.onTextItemsChange(widget.texts);
                      sendUpdateTextItem(widget.selectedTextItem!);
                    });
                  },
                  min: 10,
                  max: 250,
                ),
              ),
              OutlinedButton(
                  onPressed: () {
                    widget.toolbarOptions.colorPickerOpen =
                        !widget.toolbarOptions.colorPickerOpen;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(OwnIcons.color_lens,
                        color: widget.selectedTextItem!.color),
                  )),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.texts.remove(widget.selectedTextItem!);
                      sendTextItemDelete(widget.selectedTextItem!);
                      widget.onTextItemsChange(widget.texts);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(Icons.delete),
                  ))
            ],
          ),
        ),
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
      widget.websocketConnection!.sendDataToChannel("textitem-update#" , data);
  }

  sendTextItemDelete(TextItem newTextItem) {
    String data = jsonEncode(WSScribbleDelete(
      newTextItem.uuid,
    ));
    if (widget.websocketConnection != null)
      widget.websocketConnection!.sendDataToChannel("text-item-delete#" , data);
  }
}
