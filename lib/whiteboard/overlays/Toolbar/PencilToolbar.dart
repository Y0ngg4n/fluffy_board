import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class PencilToolbar extends StatefulWidget {
  OnColorPickerOpen onColorPickerOpen;

  PencilToolbar({required this.onColorPickerOpen});

  @override
  _PencilToolbarState createState() => _PencilToolbarState();
}

typedef OnColorPickerOpen<T> = Function();

class _PencilToolbarState extends State<PencilToolbar> {
  @override
  Widget build(BuildContext context) {
    List<bool> selectedColorList =
        List.generate(3, (i) => i == 0 ? true : false);
    const _borderRadius = 50.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: SingleChildScrollView(
          child: ToggleButtons(
              onPressed: (index) {
                widget.onColorPickerOpen();
              },
              direction: Axis.vertical,
              borderRadius: BorderRadius.circular(_borderRadius),
              isSelected: selectedColorList,
              children: <Widget>[
                Icon(OwnIcons.color_lens),
                Icon(OwnIcons.color_lens),
                Icon(OwnIcons.color_lens),
              ]),
        ),
      ),
    );
  }
}
