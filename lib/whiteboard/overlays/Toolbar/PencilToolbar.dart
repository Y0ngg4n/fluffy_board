import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedPencilColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

class PencilOptions extends DrawOptions {
  SelectedPencilColorToolbar selectedPencilColorToolbar =
      SelectedPencilColorToolbar.ColorPreset1;

  PencilOptions(this.selectedPencilColorToolbar)
      : super(List.from({Colors.black, Colors.red, Colors.blue}),
      1, StrokeCap.round, 0);
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
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);

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

                      widget.toolbarOptions.pencilOptions
                              .selectedPencilColorToolbar =
                          SelectedPencilColorToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
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
