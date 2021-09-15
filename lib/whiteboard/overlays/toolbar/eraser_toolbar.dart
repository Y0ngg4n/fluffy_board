import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../toolbar.dart' as Toolbar;

import 'draw_options.dart';


class EraserOptions extends DrawOptions {

  EraserOptions(List<Color> colors, double strokeWidth, StrokeCap strokeCap, int currentColor, dynamic Function(DrawOptions) onEraserChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onEraserChange);
}

class EncodeEraserOptions{
  double strokeWidth;

  EncodeEraserOptions(this.strokeWidth);

  Map toJson() {
    return {
      'stroke_width': strokeWidth,
    };
  }
}


class DecodeEraserOptions{
  late double strokeWidth;


  DecodeEraserOptions(this.strokeWidth);

  factory DecodeEraserOptions.fromJson(dynamic json){
    return DecodeEraserOptions(json['stroke_width'] as double);
  }
}

class EraserToolbar extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final Axis axis;
  EraserToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions, required this.axis});

  @override
  _EraserToolbarState createState() => _EraserToolbarState();
}

class _EraserToolbarState extends State<EraserToolbar> {
  late List<bool> selectedTypeList;

  @override
  void initState() {
    super.initState();
    selectedTypeList = List.generate(2, (i) => i == widget.toolbarOptions.eraserOptions.currentColor ? true : false);
  }

  @override
  Widget build(BuildContext context) {

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              RotatedBox(
                quarterTurns: widget.axis == Axis.vertical ? -1: 0,
                child: Slider.adaptive(
                  value: widget.toolbarOptions.eraserOptions.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.toolbarOptions.eraserOptions.strokeWidth = value;
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                    });
                  },
                  onChangeEnd: (value) {
                    widget.toolbarOptions.eraserOptions.onDrawOptionChange(widget.toolbarOptions.eraserOptions);
                  },
                  min: 1,
                  max: 200,
                ),
              ),
              ToggleButtons(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(widget.axis == Axis.vertical ? 50 : 0), bottomRight: Radius.circular(widget.axis == Axis.vertical ? 50 : 0)),
                isSelected: selectedTypeList,
                direction: widget.axis,
                children: [
                  Icon(OwnIcons.pencil_alt),
                  Icon(OwnIcons.highlight),
                ],
                onPressed: (index) {
                  setState(() {
                    widget.toolbarOptions.eraserOptions.currentColor = index;
                    for (int buttonIndex = 0;
                    buttonIndex < selectedTypeList.length;
                    buttonIndex++) {
                      if (buttonIndex == index) {
                        selectedTypeList[buttonIndex] = true;
                      } else {
                        selectedTypeList[buttonIndex] = false;
                      }
                    }
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    widget.toolbarOptions.eraserOptions.onDrawOptionChange(
                        widget.toolbarOptions.eraserOptions);
                  });
                },
              )
            ],
    );
  }
}
