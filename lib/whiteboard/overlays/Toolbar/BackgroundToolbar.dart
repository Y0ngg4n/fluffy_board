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
  SelectedBackgroundTypeToolbar selectedBackgroundTypeToolbar =
      SelectedBackgroundTypeToolbar.White;

  BackgroundOptions(this.selectedBackgroundTypeToolbar)
      : super(List.empty(),
      50, StrokeCap.round, 0);
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
  int beforeIndex = -1;
  int realBeforeIndex = 0;
  List<bool> selectedBackgroundTypeList = List.generate(3, (i) => i == 0 ? true : false);

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
                  min: 50,
                  max: 200,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.backgroundOptions.currentColor = index;
                      widget.toolbarOptions.colorPickerOpen =
                          !widget.toolbarOptions.colorPickerOpen;

                      for (int buttonIndex = 0;
                          buttonIndex < selectedBackgroundTypeList.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          selectedBackgroundTypeList[buttonIndex] = true;
                        } else {
                          selectedBackgroundTypeList[buttonIndex] = false;
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

                      widget.toolbarOptions.backgroundOptions.selectedBackgroundTypeToolbar =
                          SelectedBackgroundTypeToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
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
