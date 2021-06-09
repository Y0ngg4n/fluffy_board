import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ColorPickerView extends StatefulWidget {
  @override
  _ColorPickerViewState createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView> {
  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

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
                color: Colors.green,
                // Update the screenPickerColor using the callback.
                width: ScreenUtils.getScreenWidth(context) < 700 ||
                        ScreenUtils.getScreenHeight(context) < 500
                    ? 15
                    : 40,
                height: ScreenUtils.getScreenWidth(context) < 700 ||
                        ScreenUtils.getScreenHeight(context) < 500
                    ? 15
                    : 40,
                onColorChanged: (Color color) => {},
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
}
