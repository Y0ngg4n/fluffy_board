
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/draw_options.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../toolbar.dart' as Toolbar;

typedef OnChangedColor<T> = Function(List<Color>);

class ColorPickerView extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final Scribble? selectedSettingsScribble;
  final TextItem? selectedTextItemScribble;
  final WebsocketConnection? websocketConnection;

  ColorPickerView(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.selectedSettingsScribble,
      required this.websocketConnection,
      required this.selectedTextItemScribble});

  @override
  _ColorPickerViewState createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView> {
  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

    num colorPickerWidth = ScreenUtils.getScreenWidth(context) < 700
        ? ScreenUtils.getScreenWidth(context) / 2
        : 500;

     num colorPickerHeight=  ScreenUtils.getScreenHeight(context) < 700
        ? ScreenUtils.getScreenHeight(context) / 2
        : 500;

     num colorPickerItemSize = ScreenUtils.getScreenWidth(context) < 700 ||
         ScreenUtils.getScreenHeight(context) < 500
         ? 25
         : 40;

    DrawOptions? drawOptions = _getDrawOptions();
    return (Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
        child: SizedBox(
          width:  colorPickerWidth.toDouble(),
          height: colorPickerHeight.toDouble(),
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
                    ? widget.selectedSettingsScribble == null
                        ? widget.selectedTextItemScribble!.color
                        : widget.selectedSettingsScribble!.color
                    : drawOptions.colorPresets[drawOptions.currentColor],
                // Update the screenPickerColor using the callback.
                width: colorPickerItemSize.toDouble(),
                height: colorPickerItemSize.toDouble(),
                onColorChanged: (Color color) => {
                  setState(() {
                    if (drawOptions == null) {
                      if (widget.selectedSettingsScribble != null) {
                        widget.selectedSettingsScribble!.color = color;
                        WebsocketSend.sendScribbleUpdate(widget.selectedSettingsScribble!, widget.websocketConnection);
                      } else if (widget.selectedTextItemScribble != null) {
                        widget.selectedTextItemScribble!.color = color;
                        WebsocketSend.sendUpdateTextItem(widget.selectedTextItemScribble!, widget.websocketConnection);
                      }
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
                        case Toolbar.SelectedTool.text:
                          widget.toolbarOptions.textOptions
                              .onDrawOptionChange(
                              widget.toolbarOptions.textOptions);
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
      case Toolbar.SelectedTool.text:
        return widget.toolbarOptions.textOptions;
      case Toolbar.SelectedTool.figure:
        return widget.toolbarOptions.figureOptions;
      default:
        return widget.toolbarOptions.pencilOptions;
    }
  }
}
