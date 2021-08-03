import 'dart:convert';

import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../whiteboard-data/json_encodable.dart';
import '../toolbar.dart' as Toolbar;

import 'draw_options.dart';

enum SelectedTextColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

class TextOptions extends DrawOptions {
  SelectedTextColorToolbar selectedTextColorToolbar =
      SelectedTextColorToolbar.ColorPreset1;

  TextOptions(this.selectedTextColorToolbar)
      : super(List.from({Colors.black, Colors.red, Colors.blue}), 10,
            StrokeCap.round, 0, (DrawOptions) => {});
}

class TextToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  WebsocketConnection? websocketConnection;
  Axis axis;
  TextToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.websocketConnection,
      required this.axis});

  @override
  _TextToolbarState createState() => _TextToolbarState();
}

class _TextToolbarState extends State<TextToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);

  @override
  Widget build(BuildContext context) {
    // TODO: Add Update on Text when slider changed

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              RotatedBox(
                quarterTurns: widget.axis == Axis.vertical ? -1: 0,
                child: Slider.adaptive(
                  value: widget.toolbarOptions.textOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.textOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  min: 10,
                  max: 250,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.textOptions.currentColor = index;
                      widget.toolbarOptions.colorPickerOpen =
                          !widget.toolbarOptions.colorPickerOpen;

                      for (int buttonIndex = 0;
                          buttonIndex < selectedColorList.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          selectedColorList[buttonIndex] = true;
                        } else {
                          selectedColorList[buttonIndex] = false;
                        }
                      }
                      if (beforeIndex == index) {
                        widget.toolbarOptions.colorPickerOpen = false;
                        beforeIndex = -1;
                      } else if (beforeIndex == -1) {
                        widget.toolbarOptions.colorPickerOpen = false;
                        beforeIndex = -2;
                      } else if (realBeforeIndex != index) {
                        widget.toolbarOptions.colorPickerOpen = false;
                      } else {
                        widget.toolbarOptions.colorPickerOpen = true;
                        beforeIndex = index;
                      }
                      realBeforeIndex = index;

                      widget.toolbarOptions.textOptions
                              .selectedTextColorToolbar =
                          SelectedTextColorToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  direction: widget.axis,
                  isSelected: selectedColorList,
                  children: <Widget>[
                    Icon(OwnIcons.color_lens,
                        color:
                            widget.toolbarOptions.textOptions.colorPresets[0]),
                    Icon(OwnIcons.color_lens,
                        color:
                            widget.toolbarOptions.textOptions.colorPresets[1]),
                    Icon(OwnIcons.color_lens,
                        color:
                            widget.toolbarOptions.textOptions.colorPresets[2]),
                  ]),
            ],
    );
  }
}
