import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../DrawPoint.dart';
import '../../Toolbar.dart' as Toolbar;

class ScribbleSettings extends StatefulWidget {
  Scribble? selectedScribble;
  List<Scribble> scribbles;
  OnScribblesChange onScribblesChange;
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  ScribbleSettings({required this.selectedScribble,
  required this.toolbarOptions,
  required this.onChangedToolbarOptions,
  required this.scribbles,
  required this.onScribblesChange});

  @override
  _ScribbleSettingsState createState() => _ScribbleSettingsState();
}

class _ScribbleSettingsState extends State<ScribbleSettings> {
  @override
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
                  value: widget.selectedScribble!.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.selectedScribble!.strokeWidth = value;
                    });
                  },
                  min: 1,
                  max: 50,
                ),
              ),
              OutlinedButton(onPressed: () {
                widget.toolbarOptions.colorPickerOpen = true;
                widget.onChangedToolbarOptions(widget.toolbarOptions);
              }, child: Icon(OwnIcons.color_lens,
                  color: widget.selectedScribble!.color)),
              OutlinedButton(onPressed: () {
                setState(() {
                  widget.scribbles.remove(widget.selectedScribble!);
                  widget.onScribblesChange(widget.scribbles);
                });
              }, child: Icon(Icons.delete))
            ],
          ),
        ),
      ),
    );
  }
}
