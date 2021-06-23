import 'dart:convert';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/DrawOptions.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../DrawPoint.dart';
import '../Toolbar.dart' as Toolbar;

typedef OnChangedColor<T> = Function(List<Color>);

class ColorPickerView extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  Scribble? selectedSettingsScribble;
  WebsocketConnection websocketConnection;

  ColorPickerView(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.selectedSettingsScribble,
      required this.websocketConnection});

  @override
  _ColorPickerViewState createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView> {
  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;
    DrawOptions? drawOptions = _getDrawOptions();
    return (Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
        child: SizedBox(
          width: ScreenUtils.getScreenWidth(context) < 600
              ? ScreenUtils.getScreenWidth(context)
              : 500,
          height: ScreenUtils.getScreenHeight(context) < 600
              ? ScreenUtils.getScreenHeight(context)
              : 500,
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ColorPicker(
                // Use the screenPickerColor as start color.
                color: drawOptions == null
                    ? widget.selectedSettingsScribble!.color
                    : drawOptions.colorPresets[drawOptions.currentColor],
                // Update the screenPickerColor using the callback.
                width: ScreenUtils.getScreenWidth(context) < 700 ||
                        ScreenUtils.getScreenHeight(context) < 500
                    ? 15
                    : 40,
                height: ScreenUtils.getScreenWidth(context) < 700 ||
                        ScreenUtils.getScreenHeight(context) < 500
                    ? 15
                    : 40,
                onColorChanged: (Color color) => {
                  setState(() {
                    if (drawOptions == null) {
                      widget.selectedSettingsScribble!.color = color;
                      sendScribbleUpdate(widget.selectedSettingsScribble!);
                    } else {
                      drawOptions.colorPresets[drawOptions.currentColor] =
                          color;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                      switch (widget.toolbarOptions.selectedTool) {
                        case Toolbar.SelectedTool.pencil:
                          widget.toolbarOptions.pencilOptions
                              .onDrawOptionChange(
                                  widget.toolbarOptions.pencilOptions);
                          break;
                        case Toolbar.SelectedTool.highlighter:
                          widget.toolbarOptions.highlighterOptions
                              .onDrawOptionChange(
                                  widget.toolbarOptions.highlighterOptions);
                          break;
                        case Toolbar.SelectedTool.straightLine:
                          widget.toolbarOptions.straightLineOptions
                              .onDrawOptionChange(
                                  widget.toolbarOptions.straightLineOptions);
                          break;
                        default:
                          break;
                      }
                    }
                  })
                },
                borderRadius: 22,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.wheel: true,
                },
                showMaterialName: true,
                showColorName: true,
                showColorCode: true,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  longPressMenu: true,
                ),
                materialNameTextStyle: Theme.of(context).textTheme.caption,
                colorNameTextStyle: Theme.of(context).textTheme.caption,
                colorCodeTextStyle: Theme.of(context).textTheme.caption,
                heading: Text(
                  'Select color',
                  style: Theme.of(context).textTheme.headline5,
                ),
                subheading: Text(
                  'Select color shade',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ),
        )));
  }

  DrawOptions? _getDrawOptions() {
    if (widget.toolbarOptions.settingsSelected != Toolbar.SettingsSelected.none)
      return null;
    switch (widget.toolbarOptions.selectedTool) {
      case Toolbar.SelectedTool.pencil:
        return widget.toolbarOptions.pencilOptions;
      case Toolbar.SelectedTool.highlighter:
        return widget.toolbarOptions.highlighterOptions;
      case Toolbar.SelectedTool.straightLine:
        return widget.toolbarOptions.straightLineOptions;
      default:
        return widget.toolbarOptions.pencilOptions;
    }
  }

  sendScribbleUpdate(Scribble newScribble) {
    String data = jsonEncode(WSScribbleUpdate(
      newScribble.uuid,
      newScribble.strokeWidth,
      newScribble.strokeCap.index,
      newScribble.color.toHex(),
      newScribble.points,
      newScribble.paintingStyle.index,
      newScribble.leftExtremity,
      newScribble.rightExtremity,
      newScribble.topExtremity,
      newScribble.bottomExtremity,
    ));
    widget.websocketConnection.channel.add("scribble-update#" + data);
  }
}
