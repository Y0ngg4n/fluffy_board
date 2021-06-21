import 'dart:core';

import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class WSScribbleAdd{
  String uuid;
  int selectedFigureTypeToolbar;
  double strokeWidth;
  int strokeCap;
  String color;
  List<DrawPoint> points;
  int paintingStyle;

  Map toJson() {
    return {
      'uuid': uuid,
      'selected_figure_type_toolbar': selectedFigureTypeToolbar,
      'stroke_width': strokeWidth,
      'stoke_cap': strokeCap,
      'color': color,
      'points': points,
      'painting_style': paintingStyle
    };
  }

  WSScribbleAdd(
      this.uuid,
      this.selectedFigureTypeToolbar,
      this.strokeWidth,
      this.strokeCap,
      this.color,
      this.points,
      this.paintingStyle);
}

class WSScribbleUpdate{
  String uuid;
  int selectedFigureTypeToolbar;
  double strokeWidth;
  int strokeCap;
  String color;
  List<DrawPoint> points;
  int paintingStyle;
  double leftExtremity, rightExtremity, topExtremity, bottomExtremity;

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'stoke_cap': strokeCap,
      'color': color,
      'points': points,
      'painting_style': paintingStyle,
      'left_extremity': leftExtremity,
      'right_extremity': rightExtremity,
      'top_extremity': topExtremity,
      'bottom_extremity': bottomExtremity,
    };
  }

  WSScribbleUpdate(
      this.uuid,
      this.selectedFigureTypeToolbar,
      this.strokeWidth,
      this.strokeCap,
      this.color,
      this.points,
      this.paintingStyle,
      this.leftExtremity,
      this.rightExtremity,
      this.topExtremity,
      this.bottomExtremity,
      );
}