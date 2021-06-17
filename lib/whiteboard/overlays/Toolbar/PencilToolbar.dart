import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

class PencilOptions extends DrawOptions {
  PencilOptions(
      List<Color> colors,
      double strokeWidth,
      StrokeCap strokeCap,
      int currentColor,
      dynamic Function(DrawOptions) onPencilChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onPencilChange);
}

class EncodePencilOptions {
  List<String> colorPresets;
  double strokeWidth;
  int selectedColor;

  EncodePencilOptions(this.colorPresets, this.strokeWidth, this.selectedColor);

  Map toJson() {
    return {
      'color_presets': colorPresets,
      'stroke_width': strokeWidth,
      'selected_color': selectedColor,
    };
  }
}

class DecodePencilOptions {
  List<dynamic> colorPresets;
  double strokeWidth;
  int selectedColor;

  DecodePencilOptions(this.colorPresets, this.strokeWidth, this.selectedColor);

  factory DecodePencilOptions.fromJson(dynamic json) {
    return DecodePencilOptions(json['color_presets'] as List<dynamic>,
        json['stroke_width'] as double, json['selected_color'] as int);
  }
}

class PencilToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  PencilToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _PencilToolbarState createState() => _PencilToolbarState();
}

class _PencilToolbarState extends State<PencilToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  late List<bool> selectedColorList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedColorList = List.generate(3, (i) => i == widget.toolbarOptions.pencilOptions.currentColor ? true : false);
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
                  value: widget.toolbarOptions.pencilOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.pencilOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  onChangeEnd: (value) {
                    widget.toolbarOptions.pencilOptions.onDrawOptionChange(
                        widget.toolbarOptions.pencilOptions);
                  },
                  min: 1,
                  max: 50,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.pencilOptions.currentColor = index;
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
                      widget.toolbarOptions.pencilOptions.onDrawOptionChange(
                          widget.toolbarOptions.pencilOptions);
                    });
                  },
                  direction: Axis.vertical,
                  isSelected: selectedColorList,
                  children: <Widget>[
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.pencilOptions.colorPresets[0]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.pencilOptions.colorPresets[1]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.pencilOptions.colorPresets[2]),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
