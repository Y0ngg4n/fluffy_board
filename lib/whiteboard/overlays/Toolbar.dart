import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/SettingsToolbar/ScribbleSettings.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/SettingsToolbar/UploadSettings.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/TextToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/UploadToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../whiteboard-data/json_encodable.dart';
import '../WhiteboardView.dart';
import 'Toolbar/BackgroundToolbar.dart';
import 'Toolbar/ColorPickerView.dart';
import 'Toolbar/EraserToolbar.dart';
import 'Toolbar/PencilToolbar.dart';
import 'Toolbar/HighlighterToolbar.dart';
import 'Toolbar/SettingsToolbar/TextItemSettings.dart';

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
  TextOptions textOptions;
  BackgroundOptions backgroundOptions;
  bool colorPickerOpen;
  SettingsSelected settingsSelected;
  Scribble? settingsSelectedScribble;
  Upload? settingsSelectedUpload;
  TextItem? settingsSelectedTextItem;
  WebsocketConnection? websocketConnection;

  ToolbarOptions(
      this.selectedTool,
      this.pencilOptions,
      this.highlighterOptions,
      this.straightLineOptions,
      this.eraserOptions,
      this.figureOptions,
      this.textOptions,
      this.backgroundOptions,
      this.colorPickerOpen,
      this.settingsSelected,
      this.websocketConnection);
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
  OnUploadsChange onUploadsChange;
  OnTextItemsChange onTextItemsChange;
  WebsocketConnection? websocketConnection;
  List<TextItem> texts;
  OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;
  String toolbarLocation;

  Toolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.zoomOptions,
      required this.scribbles,
      required this.onScribblesChange,
      required this.onUploadsChange,
      required this.websocketConnection,
      required this.texts,
      required this.onTextItemsChange,
      required this.onSaveOfflineWhiteboard,
      required this.toolbarLocation});

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  List<bool> selectedToolList = List.generate(10, (i) => i == 0 ? true : false);

  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;
    MainAxisAlignment mainAxisAlignment;
    CrossAxisAlignment crossAxisAlignment;
    Axis axis;
    switch (widget.toolbarLocation) {
      case "left":
        mainAxisAlignment = MainAxisAlignment.start;
        crossAxisAlignment = CrossAxisAlignment.center;
        axis = Axis.vertical;
        break;
      case "right":
        mainAxisAlignment = MainAxisAlignment.end;
        crossAxisAlignment = CrossAxisAlignment.center;
        axis = Axis.vertical;
        break;
      case "top":
        mainAxisAlignment = MainAxisAlignment.start;
        crossAxisAlignment = CrossAxisAlignment.center;
        axis = Axis.horizontal;
        break;
      case "bottom":
        mainAxisAlignment = MainAxisAlignment.end;
        crossAxisAlignment = CrossAxisAlignment.center;
        axis = Axis.horizontal;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.start;
        crossAxisAlignment = CrossAxisAlignment.center;
        axis = Axis.vertical;
        break;
    }

    Widget normalToolbar = (Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: axis,
        child: (ToggleButtons(
          direction: axis,
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
                widget.toolbarOptions.selectedTool = SelectedTool.values[index];
                widget.toolbarOptions.colorPickerOpen = false;
                widget.toolbarOptions.settingsSelected = SettingsSelected.none;
                widget.toolbarOptions.settingsSelectedScribble = null;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              }
            });
          },
          isSelected: selectedToolList,
        )),
      ),
    ));

    Widget specialToolbar = (Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: SingleChildScrollView(child: _openSpecialToolbar(axis))));

    Widget settingsToolbar = (Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: SingleChildScrollView(child: _openSettingsToolbar(axis))));

    return Flex(
      direction: axis == Axis.vertical ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        widget.toolbarLocation == "bottom" ? settingsToolbar : normalToolbar,
        widget.toolbarLocation == "bottom" ? specialToolbar : specialToolbar,
        widget.toolbarLocation == "bottom" ? normalToolbar : settingsToolbar,
        _openColorPicker(),
      ],
    );
  }

  Widget _openSpecialToolbar(Axis axis) {
    switch (widget.toolbarOptions.selectedTool) {
      case SelectedTool.move:
        return Container();
      case SelectedTool.pencil:
        return PencilToolbar(
          axis: axis,
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
          axis: axis,
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
          axis: axis,
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
          axis: axis,
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
          axis: axis,
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
          axis: axis,
          websocketConnection: widget.websocketConnection,
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
          onSaveOfflineWhiteboard: () => widget.onSaveOfflineWhiteboard(),
          sessionOffset: widget.offset,
        );
      case SelectedTool.text:
        return TextToolbar(
          axis: axis,
          websocketConnection: widget.websocketConnection,
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
        return BackgroundToolbar(
            axis: axis,
            toolbarOptions: widget.toolbarOptions,
            onChangedToolbarOptions: (toolbarOptions) {
              setState(() {
                setState(() {
                  widget.toolbarOptions = toolbarOptions;
                  widget.onChangedToolbarOptions(toolbarOptions);
                });
              });
            });
    }
  }

  Widget _openSettingsToolbar(Axis axis) {
    switch (widget.toolbarOptions.settingsSelected) {
      case SettingsSelected.none:
        return Container();
        break;
      case SettingsSelected.scribble:
        return ScribbleSettings(
          offset: widget.offset,
          zoomOptions: widget.zoomOptions,
          axis: axis,
          onSaveOfflineWhiteboard: () => widget.onSaveOfflineWhiteboard(),
          websocketConnection: widget.websocketConnection,
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
              if (!scribbles
                  .contains(widget.toolbarOptions.settingsSelectedScribble)) {
                widget.toolbarOptions.settingsSelectedScribble = null;
                widget.toolbarOptions.settingsSelected = SettingsSelected.none;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              }
            });
          },
          scribbles: widget.scribbles,
        );
        break;
      case SettingsSelected.image:
        return UploadSettings(
          axis: axis,
          onSaveOfflineWhiteboard: () => widget.onSaveOfflineWhiteboard(),
          websocketConnection: widget.websocketConnection,
          selectedUpload: widget.toolbarOptions.settingsSelectedUpload,
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            });
          },
          uploads: widget.uploads,
          onUploadsChange: (uploads) {
            setState(() {
              widget.uploads = uploads;
              widget.onUploadsChange(uploads);
              if (!uploads
                  .contains(widget.toolbarOptions.settingsSelectedUpload)) {
                widget.toolbarOptions.settingsSelectedUpload = null;
                widget.toolbarOptions.settingsSelected = SettingsSelected.none;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              }
            });
          },
        );
        break;
      case SettingsSelected.text:
        return TextItemSettings(
          axis: axis,
          onSaveOfflineWhiteboard: () => widget.onSaveOfflineWhiteboard(),
          websocketConnection: widget.websocketConnection,
          selectedTextItem: widget.toolbarOptions.settingsSelectedTextItem,
          toolbarOptions: widget.toolbarOptions,
          onChangedToolbarOptions: (toolbarOptions) {
            setState(() {
              widget.toolbarOptions = toolbarOptions;
              widget.onChangedToolbarOptions(toolbarOptions);
            });
          },
          texts: widget.texts,
          onTextItemsChange: (texts) {
            setState(() {
              widget.texts = texts;
              widget.onTextItemsChange(texts);
              if (!texts
                  .contains(widget.toolbarOptions.settingsSelectedTextItem)) {
                widget.toolbarOptions.settingsSelectedTextItem = null;
                widget.toolbarOptions.settingsSelected = SettingsSelected.none;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              }
            });
          },
        );
        break;
    }
  }

  Widget _openColorPicker() {
    if (widget.toolbarOptions.colorPickerOpen)
      return ColorPickerView(
        websocketConnection: widget.websocketConnection,
        selectedSettingsScribble:
            widget.toolbarOptions.settingsSelectedScribble,
        toolbarOptions: widget.toolbarOptions,
        onChangedToolbarOptions: (toolBarOptions) {
          widget.onChangedToolbarOptions(toolBarOptions);
        },
        selectedTextItemScribble:
            widget.toolbarOptions.settingsSelectedTextItem,
      );
    else {
      return Container();
    }
  }
}
