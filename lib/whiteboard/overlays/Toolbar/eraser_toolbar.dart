import 'package:fluffy_board/utils/screen_utils.dart';
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
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  Axis axis;
  EraserToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions, required this.axis});

  @override
  _EraserToolbarState createState() => _EraserToolbarState();
}

class _EraserToolbarState extends State<EraserToolbar> {
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);

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
            ],
    );
  }
}
