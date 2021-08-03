import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../toolbar.dart' as Toolbar;

import 'draw_options.dart';

enum SelectedStraightLineColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

enum SelectedStraightLineCapToolbar { Normal, Arrow }

class StraightLineOptions extends DrawOptions {
  int selectedCap;

  StraightLineOptions(this.selectedCap,
      List<Color> colors, double strokeWidth, StrokeCap strokeCap, int currentColor, dynamic Function(DrawOptions) onStraightLineChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onStraightLineChange);
}

class EncodeStraightLineOptions{
  List<String> colorPresets;
  double strokeWidth;
  int selectedColor;
  int selectedCap;

  EncodeStraightLineOptions(this.colorPresets, this.strokeWidth, this.selectedColor, this.selectedCap);

  Map toJson() {
    return {
      'color_presets': colorPresets,
      'stroke_width': strokeWidth,
      'selected_color': selectedColor,
      'selected_cap': selectedCap,
    };
  }
}

class DecodeStraightLineOptions{
  List<dynamic> colorPresets;
  double strokeWidth;
  int selectedColor;
  int selectedCap;

  DecodeStraightLineOptions(this.colorPresets, this.strokeWidth, this.selectedColor, this.selectedCap);

  factory DecodeStraightLineOptions.fromJson(dynamic json){
    return DecodeStraightLineOptions(json['color_presets'] as List<dynamic>, json['stroke_width'] as double,
    json['selected_color'] as int, json['selected_cap'] as int);
  }
}

class StraightLineToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  Axis axis;
  StraightLineToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions, required this.axis});

  @override
  _StraightLineToolbarState createState() => _StraightLineToolbarState();
}

class _StraightLineToolbarState extends State<StraightLineToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  late List<bool> selectedColorList;
  late List<bool> selectedCapList;

  @override
  void initState() {
    super.initState();
    selectedColorList = List.generate(3, (i) => i == widget.toolbarOptions.straightLineOptions.currentColor ? true : false);
    selectedCapList = List.generate(2, (i) => i == widget.toolbarOptions.straightLineOptions.selectedCap ? true : false);
  }

  @override
  Widget build(BuildContext context) {

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              RotatedBox(
                quarterTurns: widget.axis == Axis.vertical ? -1: 0,
                child: Slider.adaptive(
                  value: widget.toolbarOptions.straightLineOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.straightLineOptions.strokeWidth =
                          value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  onChangeEnd: (value) {
                    widget.toolbarOptions.straightLineOptions.onDrawOptionChange(widget.toolbarOptions.straightLineOptions);
                  },
                  min: 1,
                  max: 50,
                ),
              ),
              ToggleButtons(
                isSelected: selectedCapList,
                direction: widget.axis,
                children: <Widget>[
                  Icon(Icons.remove),
                  Icon(Icons.arrow_forward),
                ],
                onPressed: (index) {
                  widget.toolbarOptions.straightLineOptions.selectedCap = index;
                  for (int buttonIndex = 0;
                      buttonIndex < selectedCapList.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      selectedCapList[buttonIndex] = true;
                    } else {
                      selectedCapList[buttonIndex] = false;
                    }
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    widget.toolbarOptions.straightLineOptions.onDrawOptionChange(
                        widget.toolbarOptions.straightLineOptions);
                  }
                },
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.straightLineOptions.currentColor =
                          index;
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
                      widget.toolbarOptions.straightLineOptions.onDrawOptionChange(
                          widget.toolbarOptions.straightLineOptions);
                    });
                  },
                  direction: widget.axis,
                  isSelected: selectedColorList,
                  children: <Widget>[
                    Icon(OwnIcons.color_lens,
                        color: widget.toolbarOptions.straightLineOptions
                            .colorPresets[0]),
                    Icon(OwnIcons.color_lens,
                        color: widget.toolbarOptions.straightLineOptions
                            .colorPresets[1]),
                    Icon(OwnIcons.color_lens,
                        color: widget.toolbarOptions.straightLineOptions
                            .colorPresets[2]),
                  ]),
            ],
    );
  }
}
