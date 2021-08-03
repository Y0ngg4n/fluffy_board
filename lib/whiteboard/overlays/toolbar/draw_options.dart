import 'package:flutter/material.dart';
import 'dart:ui';

typedef OnDrawOptionChange = Function(DrawOptions);

class DrawOptions {
  List<Color> colorPresets = List.from({Colors.black, Colors.red, Colors.blue});
  double strokeWidth = 1;
  StrokeCap strokeCap = StrokeCap.round;
  int currentColor = 0;
  OnDrawOptionChange onDrawOptionChange;

  DrawOptions(this.colorPresets, this.strokeWidth, this.strokeCap, this.currentColor, this.onDrawOptionChange);
}