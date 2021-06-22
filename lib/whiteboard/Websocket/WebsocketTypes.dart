import 'dart:convert';
import 'dart:core';

import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class WSScribbleAdd {
  String uuid;
  int selectedFigureTypeToolbar;
  double strokeWidth;
  int strokeCap;
  String color;
  List<DrawPoint> points;
  int paintingStyle;

  // named constructor
  static List<DrawPoint> fromJsonList(List<dynamic> jsonList) {
    List<DrawPoint> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DrawPoint.fromJson(json));
    }
    return points;
  }

  WSScribbleAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        selectedFigureTypeToolbar = json['selected_figure_type_toolbar'],
        strokeWidth = json['stroke_width'],
        strokeCap = json['stroke_cap'],
        color = json['color'],
        points = WSScribbleAdd.fromJsonList(json['points']),
        paintingStyle = json['painting_style'];

  Map toJson() {
    return {
      'uuid': uuid,
      'selected_figure_type_toolbar': selectedFigureTypeToolbar,
      'stroke_width': strokeWidth,
      'stroke_cap': strokeCap,
      'color': color,
      'points': points,
      'painting_style': paintingStyle
    };
  }

  WSScribbleAdd(this.uuid, this.selectedFigureTypeToolbar, this.strokeWidth,
      this.strokeCap, this.color, this.points, this.paintingStyle);
}

class WSScribbleUpdate {
  String uuid;
  double strokeWidth;
  int strokeCap;
  String color;
  List<DrawPoint> points;
  int paintingStyle;
  double leftExtremity, rightExtremity, topExtremity, bottomExtremity;

  // named constructor
  static List<DrawPoint> fromJsonList(List<dynamic> jsonList) {
    List<DrawPoint> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DrawPoint.fromJson(json));
    }
    return points;
  }

  WSScribbleUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'],
        strokeCap = json['stroke_cap'],
        color = json['color'],
        points = WSScribbleAdd.fromJsonList(json['points']),
        paintingStyle = json['painting_style'],
        leftExtremity = json['left_extremity'],
        rightExtremity = json['right_extremity'],
        topExtremity = json['top_extremity'],
        bottomExtremity = json['bottom_extremity'];

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'stroke_cap': strokeCap,
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

class WSScribbleDelete {
  String uuid;

  WSScribbleDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSScribbleDelete(
    this.uuid,
  );
}
