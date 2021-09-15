import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../toolbar.dart' as Toolbar;
import 'draw_options.dart';

class TextOptions extends DrawOptions {
  TextOptions(List<Color> colors, double strokeWidth, StrokeCap strokeCap,
      int currentColor, dynamic Function(DrawOptions) onTextItemChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onTextItemChange);
}

class DecodeTextItemOptions {
  List<dynamic> colorPresets;
  double strokeWidth;
  int selectedColor;

  DecodeTextItemOptions(
      this.colorPresets, this.strokeWidth, this.selectedColor);

  factory DecodeTextItemOptions.fromJson(dynamic json) {
    return DecodeTextItemOptions(
      json['color_presets'] as List<dynamic>,
      json['stroke_width'] as double,
      json['selected_color'] as int,
    );
  }
}

class EncodeTextItemOptions {
  List<String> colorPresets;
  double strokeWidth;
  int selectedColor;

  EncodeTextItemOptions(
      this.colorPresets, this.strokeWidth, this.selectedColor);

  Map toJson() {
    return {
      'color_presets': colorPresets,
      'stroke_width': strokeWidth,
      'selected_color': selectedColor,
    };
  }
}

class TextToolbar extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final WebsocketConnection? websocketConnection;
  final Axis axis;

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
  late List<bool> selectedColorList;

  @override
  void initState() {
    selectedColorList = List.generate(
        3,
        (i) =>
            i == widget.toolbarOptions.textOptions.currentColor ? true : false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add Update on Text when slider changed

    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.axis,
      children: [
        RotatedBox(
          quarterTurns: widget.axis == Axis.vertical ? -1 : 0,
          child: Slider.adaptive(
            value: widget.toolbarOptions.textOptions.strokeWidth,
            onChanged: (value) {
              setState(() {
                widget.toolbarOptions.textOptions.strokeWidth = value;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              });
            },
            onChangeEnd: (value) {
              widget.toolbarOptions.textOptions
                  .onDrawOptionChange(widget.toolbarOptions.textOptions);
            },
            min: 10,
            max: 250,
          ),
        ),
        ToggleButtons(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(widget.axis == Axis.vertical ? 50 : 0), bottomRight: Radius.circular(widget.axis == Axis.vertical ? 50 : 0)),
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

                widget.onChangedToolbarOptions(widget.toolbarOptions);
                widget.toolbarOptions.textOptions
                    .onDrawOptionChange(widget.toolbarOptions.textOptions);
              });
            },
            direction: widget.axis,
            isSelected: selectedColorList,
            children: <Widget>[
              Icon(OwnIcons.color_lens,
                  color: widget.toolbarOptions.textOptions.colorPresets[0]),
              Icon(OwnIcons.color_lens,
                  color: widget.toolbarOptions.textOptions.colorPresets[1]),
              Icon(OwnIcons.color_lens,
                  color: widget.toolbarOptions.textOptions.colorPresets[2]),
            ]),
      ],
    );
  }
}
