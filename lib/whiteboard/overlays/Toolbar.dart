import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/SettingsToolbar/ScribbleSettings.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/TextToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/UploadToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../DrawPoint.dart';
import 'Toolbar/BackgroundToolbar.dart';
import 'Toolbar/ColorPickerView.dart';
import 'Toolbar/EraserToolbar.dart';
import 'Toolbar/PencilToolbar.dart';
import 'Toolbar/HighlighterToolbar.dart';

enum SettingsSelected { none, scribble, image, text }

enum SelectedTool {
  move,
  settings,
  pencil,
  eraser,
  highlighter,
  straightLine,
  text,
  figure,
  upload,
  background
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
  TextOptions textOptions;
  BackgroundOptions backgroundOptions;
  bool colorPickerOpen;
  SettingsSelected settingsSelected;
  Scribble? settingsSelectedScribble;
  Upload? settingsSelectedUpload;

  ToolbarOptions(
      this.selectedTool,
      this.pencilOptions,
      this.highlighterOptions,
      this.straightLineOptions,
      this.eraserOptions,
      this.figureOptions,
      this.uploadOptions,
      this.textOptions,
      this.backgroundOptions,
      this.colorPickerOpen,
      this.settingsSelected
      );
}

class Toolbar extends StatefulWidget {
  ToolbarOptions toolbarOptions;
  OnChangedToolbarOptions onChangedToolbarOptions;
  List<Upload> uploads;
  Offset offset;
  Offset sessionOffset;
  ZoomOptions zoomOptions;
  List<Scribble> scribbles;
  OnScribblesChange onScribblesChange;

  Toolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.zoomOptions,
      required this.scribbles,
      required this.onScribblesChange});

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
                Icon(Icons.settings),
                Icon(OwnIcons.pencil_alt),
                Icon(OwnIcons.eraser),
                Icon(OwnIcons.highlight),
                Icon(OwnIcons.flow_line),
                Icon(OwnIcons.text_fields),
                Icon(OwnIcons.change_history),
                Icon(Icons.file_upload_outlined),
                Icon(Icons.grid_4x4),
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
                    widget.toolbarOptions.settingsSelected =
                        SettingsSelected.none;
                    widget.toolbarOptions.settingsSelectedScribble = null;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  }
                });
              },
              isSelected: selectedToolList,
            )),
          ),
        ),
        _openSpecialToolbar(),
        _openSettingsToolbar(),
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
          uploads: widget.uploads,
          zoomOptions: widget.zoomOptions,
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
          offset: widget.offset,
          sessionOffset: widget.offset,
        );
      case SelectedTool.text:
        return TextToolbar(
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) => {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            })
          },
        );
      case SelectedTool.settings:
        return Container();
      case SelectedTool.background:
        return BackgroundToolbar(toolbarOptions: widget.toolbarOptions, onChangedToolbarOptions: (toolbarOptions) {
          setState(() {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            });
          });
        });
    }
  }

  Widget _openSettingsToolbar() {
    switch (widget.toolbarOptions.settingsSelected) {
      case SettingsSelected.none:
        return Container();
        break;
      case SettingsSelected.scribble:
        return ScribbleSettings(
            toolbarOptions: widget.toolbarOptions,
            selectedScribble: widget.toolbarOptions.settingsSelectedScribble,
            onChangedToolbarOptions: (toolbarOptions) {
              setState(() {
                widget.toolbarOptions = toolbarOptions;
                widget.onChangedToolbarOptions(toolbarOptions);
              });
            },
            onScribblesChange: (scribbles) {
              setState(() {
                widget.scribbles = scribbles;
                widget.onScribblesChange(scribbles);
              });
            }, scribbles: widget.scribbles,);
        break;
      case SettingsSelected.image:
        return Container();
        break;
      case SettingsSelected.text:
        return Container();
        break;
    }
  }

  Widget _openColorPicker() {
    if (widget.toolbarOptions.colorPickerOpen)
      return ColorPickerView(
        selectedSettingsScribble:
            widget.toolbarOptions.settingsSelectedScribble,
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
