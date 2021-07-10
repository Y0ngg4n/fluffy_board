import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedFigureTypeToolbar {
  none,
  rect,
  triangle,
  circle,
}

class FigureOptions extends DrawOptions {
  int selectedFigure;
  int selectedFill;


  FigureOptions(this.selectedFigure, this.selectedFill,
      List<Color> colors, double strokeWidth, StrokeCap strokeCap, int currentColor, dynamic Function(DrawOptions) onFigureChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onFigureChange);
}

class EncodeFigureOptions{
  List<String> colorPresets;
  double strokeWidth;
  int selectedColor;
  int selectedFigure;
  int selectedFill;

  EncodeFigureOptions(this.colorPresets, this.strokeWidth, this.selectedColor, this.selectedFigure, this.selectedFill);

  Map toJson() {
    return {
      'color_presets': colorPresets,
      'stroke_width': strokeWidth,
      'selected_color': selectedColor,
      'selected_figure': selectedFigure,
      'selected_fill': selectedFill,
    };
  }
}

class DecodeFigureptions{
  List<dynamic> colorPresets;
  double strokeWidth;
  int selectedColor;
  int selectedFigure;
  int selectedFill;

  DecodeFigureptions(this.colorPresets, this.strokeWidth, this.selectedColor, this.selectedFigure, this.selectedFill);

  factory DecodeFigureptions.fromJson(dynamic json){
    return DecodeFigureptions(json['color_presets'] as List<dynamic>, json['stroke_width'] as double,
        json['selected_color'] as int, json['selected_figure'] as int, json['selected_fill'] as int);
  }
}

class FigureToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  Axis axis;
  FigureToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions, required this.axis});

  @override
  _FigureToolbarState createState() => _FigureToolbarState();
}

class _FigureToolbarState extends State<FigureToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  late List<bool> selectedColorList;
  late List<bool> selectedTypeList;
  late List<bool> selectedPaintingStyle;

  @override
  void initState() {
    super.initState();
    selectedColorList = List.generate(3, (i) => i == widget.toolbarOptions.figureOptions.currentColor ? true : false);
    selectedTypeList = List.generate(3, (i) => i == widget.toolbarOptions.figureOptions.selectedFigure - 1 ? true : false);
    selectedPaintingStyle = List.generate(2, (i) => i == widget.toolbarOptions.figureOptions.selectedFill ? true : false);
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
                  value: widget.toolbarOptions.figureOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.figureOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  onChangeEnd: (value) {
                    widget.toolbarOptions.figureOptions.onDrawOptionChange(widget.toolbarOptions.figureOptions);
                  },
                  min: 1,
                  max: 50,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.figureOptions.currentColor = index;
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
                      widget.toolbarOptions.figureOptions.onDrawOptionChange(
                          widget.toolbarOptions.figureOptions);
                    });
                  },
                  direction: widget.axis,
                  isSelected: selectedColorList,
                  children: <Widget>[
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.figureOptions.colorPresets[0]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.figureOptions.colorPresets[1]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.figureOptions.colorPresets[2]),
                  ]),
              ToggleButtons(
                isSelected: selectedTypeList,
                direction: widget.axis,
                children: [
                  Icon(OwnIcons.check_box_outline_blank),
                  Icon(OwnIcons.change_history),
                  Icon(OwnIcons.circle_empty),
                ],
                onPressed: (index) {
                  widget.toolbarOptions.figureOptions.selectedFigure = index + 1;
                  setState(() {
                    for (int buttonIndex = 0;
                    buttonIndex < selectedTypeList.length;
                    buttonIndex++) {
                      if (buttonIndex == index) {
                        selectedTypeList[buttonIndex] = true;
                      } else {
                        selectedTypeList[buttonIndex] = false;
                      }
                    }
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    widget.toolbarOptions.figureOptions.onDrawOptionChange(
                        widget.toolbarOptions.figureOptions);
                  });
                },
              ),
              ToggleButtons(
                isSelected: selectedPaintingStyle,
                direction: widget.axis,
                children: [
                  Icon(OwnIcons.fill_drip),
                  Icon(OwnIcons.timeline),
                ],
                onPressed: (index) {
                  setState(() {
                    widget.toolbarOptions.figureOptions.selectedFill = index;
                    for (int buttonIndex = 0;
                    buttonIndex < selectedPaintingStyle.length;
                    buttonIndex++) {
                      if (buttonIndex == index) {
                        selectedPaintingStyle[buttonIndex] = true;
                      } else {
                        selectedPaintingStyle[buttonIndex] = false;
                      }
                    }
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    widget.toolbarOptions.figureOptions.onDrawOptionChange(
                        widget.toolbarOptions.figureOptions);
                  });
                },
              )
            ],
    );
  }
}
