import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';


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

  EraserToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _EraserToolbarState createState() => _EraserToolbarState();
}

class _EraserToolbarState extends State<EraserToolbar> {
  List<bool> selectedColorList = List.generate(3, (i) => i == 0 ? true : false);

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
          ),
        ),
      ),
    );
  }
}
