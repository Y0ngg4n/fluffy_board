import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/UploadToolbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'Toolbar/ColorPickerView.dart';
import 'Toolbar/EraserToolbar.dart';
import 'Toolbar/PencilToolbar.dart';
import 'Toolbar/HighlighterToolbar.dart';

enum SelectedTool {
  move,
  pencil,
  eraser,
  highlighter,
  straightLine,
  figure,
  upload,
}

typedef OnChangedToolbarOptions<T> = Function(ToolbarOptions);

class ToolbarOptions {
  SelectedTool selectedTool;
  PencilOptions pencilOptions;
  HighlighterOptions highlighterOptions;
  StraightLineOptions straightLineOptions;
  EraserOptions eraserOptions;
  FigureOptions figureOptions;
  UploadOptions uploadOptions;
  bool colorPickerOpen;

  ToolbarOptions(this.selectedTool, this.pencilOptions, this.highlighterOptions,
      this.straightLineOptions,
      this.eraserOptions,
      this.figureOptions,
      this.uploadOptions,
      this.colorPickerOpen);
}

class Toolbar extends StatefulWidget {
  ToolbarOptions toolbarOptions;
  OnChangedToolbarOptions onChangedToolbarOptions;

  Toolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  List<bool> selectedToolList = List.generate(10, (i) => i == 0 ? true : false);

  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

    return Row(
      children: [
        Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: (ToggleButtons(
              direction: Axis.vertical,
              borderRadius: BorderRadius.circular(_borderRadius),
              children: <Widget>[
                Icon(OwnIcons.move),
                Icon(OwnIcons.pencil_alt),
                Icon(OwnIcons.eraser),
                Icon(OwnIcons.highlight),
                Icon(OwnIcons.flow_line),
                Icon(OwnIcons.change_history),
                Icon(Icons.file_upload_outlined),
                Icon(Icons.cake),
                Icon(Icons.cake),
                Icon(Icons.cake),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < selectedToolList.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      selectedToolList[buttonIndex] = true;
                    } else {
                      selectedToolList[buttonIndex] = false;
                    }
                    widget.toolbarOptions.selectedTool =
                        SelectedTool.values[index];
                    widget.toolbarOptions.colorPickerOpen = false;
                  }
                });
              },
              isSelected: selectedToolList,
            )),
          ),
        ),
        _openSpecialToolbar(),
        _openColorPicker(),
      ],
    );
  }

  Widget _openSpecialToolbar() {
    switch (widget.toolbarOptions.selectedTool) {
      case SelectedTool.move:
        return Container();
      case SelectedTool.pencil:
        return PencilToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.highlighter:
        return HighlighterToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.straightLine:
        return StraightLineToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.eraser:
        return EraserToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.figure:
        return FigureToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.upload:
        return UploadToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      default:
        return Container();
    }
  }

  Widget _openColorPicker() {
    if (widget.toolbarOptions.colorPickerOpen)
      return ColorPickerView(
        toolbarOptions: widget.toolbarOptions,
        onChangedToolbarOptions: (toolBarOptions) {
          widget.onChangedToolbarOptions(toolBarOptions);
        },
      );
    else {
      return Container();
    }
  }
}
