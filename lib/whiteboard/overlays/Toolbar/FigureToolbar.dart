import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedFigureColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

enum SelectedFigureTypeToolbar {
  none,
  rect,
  triangle,
  circle,
}

class FigureOptions extends DrawOptions {
  SelectedFigureColorToolbar selectedFigureColorToolbar =
      SelectedFigureColorToolbar.ColorPreset1;

  SelectedFigureTypeToolbar selectedFigureTypeToolbar =
      SelectedFigureTypeToolbar.rect;

  PaintingStyle paintingStyle = PaintingStyle.stroke;

  FigureOptions(this.selectedFigureColorToolbar, this.selectedFigureTypeToolbar, this.paintingStyle)
      : super(List.from({Colors.black, Colors.red, Colors.blue}), 1,
            StrokeCap.round, 0, (DrawOptions)=>{});
}

class FigureToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  FigureToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _FigureToolbarState createState() => _FigureToolbarState();
}

class _FigureToolbarState extends State<FigureToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);
  List<bool> selectedTypeList = List.generate(3, (i) => i == 0 ? true : false);
  List<bool> selectedPaintingStyle = List.generate(2, (i) => i == 1 ? true : false);

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
                  value: widget.toolbarOptions.figureOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.figureOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
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

                      widget.toolbarOptions.figureOptions
                              .selectedFigureColorToolbar =
                          SelectedFigureColorToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  direction: Axis.vertical,
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
                direction: Axis.vertical,
                children: [
                  Icon(OwnIcons.check_box_outline_blank),
                  Icon(OwnIcons.change_history),
                  Icon(OwnIcons.circle_empty),
                ],
                onPressed: (index) {
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
                    widget.toolbarOptions.figureOptions
                            .selectedFigureTypeToolbar =
                        SelectedFigureTypeToolbar.values[index + 1];
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  });
                },
              ),
              ToggleButtons(
                isSelected: selectedPaintingStyle,
                direction: Axis.vertical,
                children: [
                  Icon(OwnIcons.fill_drip),
                  Icon(OwnIcons.timeline),
                ],
                onPressed: (index) {
                  setState(() {
                    for (int buttonIndex = 0;
                    buttonIndex < selectedPaintingStyle.length;
                    buttonIndex++) {
                      if (buttonIndex == index) {
                        selectedPaintingStyle[buttonIndex] = true;
                      } else {
                        selectedPaintingStyle[buttonIndex] = false;
                      }
                    }
                    widget.toolbarOptions.figureOptions
                        .paintingStyle =
                    PaintingStyle.values[index];
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
