import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedHighlighterColorToolbar {
  ColorPreset1,
  ColorPreset2,
  ColorPreset3,
}

class HighlighterOptions extends DrawOptions {
  SelectedHighlighterColorToolbar selectedHighlighterColorToolbar =
      SelectedHighlighterColorToolbar.ColorPreset1;

  HighlighterOptions(this.selectedHighlighterColorToolbar)
      : super(
            List.from({Colors.limeAccent, Colors.lightGreen, Colors.lightBlue}),
            5,
            StrokeCap.square,
            0);
}

class HighlighterToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  HighlighterToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _HighlighterToolbarState createState() => _HighlighterToolbarState();
}

class _HighlighterToolbarState extends State<HighlighterToolbar> {
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
                  value: widget.toolbarOptions.highlighterOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.highlighterOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  min: 5,
                  max: 50,
                ),
              ),
              ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      widget.toolbarOptions.highlighterOptions.currentColor =
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

                      widget.toolbarOptions.highlighterOptions
                              .selectedHighlighterColorToolbar =
                          SelectedHighlighterColorToolbar.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  direction: Axis.vertical,
                  isSelected: selectedColorList,
                  children: <Widget>[
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.highlighterOptions.colorPresets[0]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.highlighterOptions.colorPresets[1]),
                    Icon(OwnIcons.color_lens,
                        color: widget
                            .toolbarOptions.highlighterOptions.colorPresets[2]),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
