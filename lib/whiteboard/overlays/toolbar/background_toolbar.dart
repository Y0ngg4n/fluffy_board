import 'package:flutter/material.dart';
import 'dart:ui';

import '../toolbar.dart' as Toolbar;

import 'draw_options.dart';

enum SelectedBackgroundTypeToolbar {
  White,
  Grid,
  Lines,
}

class BackgroundOptions extends DrawOptions {
  int selectedBackground;

  BackgroundOptions(
      this.selectedBackground,
      List<Color> colors,
      double strokeWidth,
      StrokeCap strokeCap,
      int currentColor,
      dynamic Function(DrawOptions) onBackgroundChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onBackgroundChange);
}

class EncodeBackgroundOptions {
  double strokeWidth;
  int selectedBackground;

  EncodeBackgroundOptions(this.strokeWidth, this.selectedBackground);

  Map toJson() {
    return {
      'stroke_width': strokeWidth,
      'selected_background': selectedBackground,
    };
  }
}

class DecodeBackgroundOptions {
  double strokeWidth;
  int selectedBackground;

  DecodeBackgroundOptions(this.strokeWidth, this.selectedBackground);

  factory DecodeBackgroundOptions.fromJson(dynamic json) {
    return DecodeBackgroundOptions(
        json['stroke_width'] as double, json['selected_background'] as int);
  }
}

class BackgroundToolbar extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final Axis axis;

  BackgroundToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.axis});

  @override
  _BackgroundToolbarState createState() => _BackgroundToolbarState();
}

class _BackgroundToolbarState extends State<BackgroundToolbar> {
  late List<bool> selectedBackgroundTypeList;

  @override
  void initState() {
    // TODO: implement initState
    selectedBackgroundTypeList = List.generate(
        3,
        (i) => i == widget.toolbarOptions.backgroundOptions.selectedBackground
            ? true
            : false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.axis,
      children: [
        RotatedBox(
          quarterTurns: widget.axis == Axis.vertical ? -1 : 0,
          child: Slider.adaptive(
            value: widget.toolbarOptions.backgroundOptions.strokeWidth,
            onChanged: (value) {
              setState(() {
                widget.toolbarOptions.backgroundOptions.strokeWidth = value;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              });
            },
            onChangeEnd: (value) {
              widget.toolbarOptions.backgroundOptions
                  .onDrawOptionChange(widget.toolbarOptions.backgroundOptions);
            },
            min: 50,
            max: 200,
          ),
        ),
        ToggleButtons(
            onPressed: (index) {
              setState(() {
                widget.toolbarOptions.backgroundOptions.selectedBackground =
                    index;

                for (int buttonIndex = 0;
                    buttonIndex < selectedBackgroundTypeList.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    selectedBackgroundTypeList[buttonIndex] = true;
                  } else {
                    selectedBackgroundTypeList[buttonIndex] = false;
                  }
                }

                widget.onChangedToolbarOptions(widget.toolbarOptions);
                widget.toolbarOptions.backgroundOptions.onDrawOptionChange(
                    widget.toolbarOptions.backgroundOptions);
              });
            },
            direction: widget.axis,
            isSelected: selectedBackgroundTypeList,
            children: <Widget>[
              Icon(Icons.crop_3_2),
              Icon(Icons.grid_4x4),
              Icon(Icons.drag_handle),
            ]),
      ],
    );
  }
}
