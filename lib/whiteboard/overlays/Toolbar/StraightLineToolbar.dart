import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedStraightLineColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

enum SelectedStraightLineCapToolbar { Normal, Arrow }

class StraightLineOptions extends DrawOptions {
  SelectedStraightLineColorToolbar selectedStraightLineColorToolbar =
      SelectedStraightLineColorToolbar.ColorPreset1;

  SelectedStraightLineCapToolbar selectedStraightLineCapToolbar =
      SelectedStraightLineCapToolbar.Normal;

  StraightLineOptions(this.selectedStraightLineColorToolbar,
      this.selectedStraightLineCapToolbar)
      : super(List.from({Colors.black, Colors.red, Colors.blue}), 1,
            StrokeCap.round, 0);
}

class StraightLineToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  StraightLineToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _StraightLineToolbarState createState() => _StraightLineToolbarState();
}

class _StraightLineToolbarState extends State<StraightLineToolbar> {
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);
  List<bool> selectedCapList = List.generate(2, (i) => i == 0 ? true : false);

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
                  value: widget.toolbarOptions.straightLineOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.straightLineOptions.strokeWidth =
                          value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  min: 1,
                  max: 50,
                ),
              ),
              ToggleButtons(
                isSelected: selectedCapList,
                direction: Axis.vertical,
                children: <Widget>[
                  Icon(Icons.remove),
                  Icon(Icons.arrow_forward),
                ],
                onPressed: (index) {
                  for (int buttonIndex = 0;
                      buttonIndex < selectedCapList.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      selectedCapList[buttonIndex] = true;
                    } else {
                      selectedCapList[buttonIndex] = false;
                    }
                    widget.toolbarOptions.straightLineOptions
                            .selectedStraightLineCapToolbar =
                        SelectedStraightLineCapToolbar.values[index];
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
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

                      widget.toolbarOptions
                        ..straightLineOptions.selectedStraightLineColorToolbar =
                            SelectedStraightLineColorToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  direction: Axis.vertical,
                  borderRadius: BorderRadius.circular(_borderRadius),
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
          ),
        ),
      ),
    );
  }
}
