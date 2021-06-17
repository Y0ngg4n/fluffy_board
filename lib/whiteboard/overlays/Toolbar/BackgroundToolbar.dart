import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedBackgroundTypeToolbar {
  White,
  Grid,
  Lines,
}

class BackgroundOptions extends DrawOptions {
  int selectedBackground;

  BackgroundOptions(this.selectedBackground,
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
    return DecodeBackgroundOptions(json['stroke_width'] as double, json['selected_background'] as int);
  }
}


class BackgroundToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  BackgroundToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _BackgroundToolbarState createState() => _BackgroundToolbarState();
}

class _BackgroundToolbarState extends State<BackgroundToolbar> {
  late List<bool> selectedBackgroundTypeList;

  @override
  void initState() {
    // TODO: implement initState
    selectedBackgroundTypeList = List.generate(3, (i) => i == widget.toolbarOptions.backgroundOptions.selectedBackground ? true : false);
    super.initState();
  }

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
                  value: widget.toolbarOptions.backgroundOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.backgroundOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  onChangeEnd: (value){
                    widget.toolbarOptions.backgroundOptions.onDrawOptionChange(
                        widget.toolbarOptions.backgroundOptions);
                  },
                  min: 50,
                  max: 200,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.backgroundOptions.selectedBackground = index;

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
                  direction: Axis.vertical,
                  isSelected: selectedBackgroundTypeList,
                  children: <Widget>[
                    Icon(Icons.crop_3_2),
                    Icon(Icons.grid_4x4),
                    Icon(Icons.drag_handle),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
