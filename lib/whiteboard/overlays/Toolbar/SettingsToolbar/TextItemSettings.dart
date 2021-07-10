import 'dart:convert';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../DrawPoint.dart';
import '../../../WhiteboardView.dart';
import '../../Toolbar.dart' as Toolbar;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class TextItemSettings extends StatefulWidget {
  TextItem? selectedTextItem;
  List<TextItem> texts;
  OnTextItemsChange onTextItemsChange;
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  WebsocketConnection? websocketConnection;
  OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;

  TextItemSettings(
      {required this.selectedTextItem,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.texts,
      required this.onTextItemsChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard});

  @override
  _TextItemSettingsState createState() => _TextItemSettingsState();
}

class _TextItemSettingsState extends State<TextItemSettings> {

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
                    });
                  },
                  onChangeEnd: (value) {
                    widget.onSaveOfflineWhiteboard();
                      WebsocketSend.sendUpdateTextItem(widget.selectedTextItem!, widget.websocketConnection);
                  },
                  min: 10,
                  max: 250,
                ),
              ),
              SleekCircularSlider(
                appearance: CircularSliderAppearance(
                    size: 50,
                    startAngle: 270,
                    angleRange: 360,
                    infoProperties: InfoProperties(modifier: (double value) {
                      final roundedValue = value.ceil().toInt().toString();
                      return '$roundedValue °';
                    })),
                initialValue: widget.selectedTextItem!.rotation,
                min: 0,
                max: 360,
                onChange: (value) {
                  setState(() {
                    widget.selectedTextItem!.rotation = value;
                  });
                },
                onChangeEnd: (value) async {
                  print(value);
                  int index = widget.texts.indexOf(widget.selectedTextItem!);
                  widget.texts[index] = widget.selectedTextItem!;
                  widget.onTextItemsChange(widget.texts);
                  widget.onSaveOfflineWhiteboard();
                  WebsocketSend.sendUpdateTextItem(widget.selectedTextItem!, widget.websocketConnection);
                },
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
                      widget.onTextItemsChange(widget.texts);
                      widget.onSaveOfflineWhiteboard();
                      WebsocketSend.sendTextItemDelete(widget.selectedTextItem!, widget.websocketConnection);
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
}
