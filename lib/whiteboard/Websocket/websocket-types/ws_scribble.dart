import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/draw_point.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/json_encodable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class WSScribbleAdd implements JsonWebSocketType {
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
        strokeWidth = json['stroke_width'].toDouble(),
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

class WSScribbleUpdate implements JsonWebSocketType {
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
        strokeWidth = json['stroke_width'].toDouble(),
        strokeCap = json['stroke_cap'],
        color = json['color'],
        points = WSScribbleAdd.fromJsonList(json['points']),
        paintingStyle = json['painting_style'],
        leftExtremity = json['left_extremity'].toDouble(),
        rightExtremity = json['right_extremity'].toDouble(),
        topExtremity = json['top_extremity'].toDouble(),
        bottomExtremity = json['bottom_extremity'].toDouble();

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

class WSScribbleDelete implements JsonWebSocketType {
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

class DecodeGetScribbleList implements DecodeGetJsonWebSocketTypeList{
  static List<DecodeGetScribble> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetScribble> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetScribble.fromJson(json));
    }
    return points;
  }
}

class DecodeGetScribble implements DecodeGetJsonWebSocketType{
  String uuid;
  int selectedFigureTypeToolbar;
  double strokeWidth;
  int strokeCap;
  String color;
  List<DrawPoint> points;
  int paintingStyle;
  double leftExtremity, rightExtremity, topExtremity, bottomExtremity;

  static List<DrawPoint> fromJsonList(List<dynamic> jsonList) {
    List<DrawPoint> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DrawPoint.fromJson(json));
    }
    return points;
  }

  DecodeGetScribble(
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
      this.bottomExtremity);

  DecodeGetScribble.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        selectedFigureTypeToolbar = json['selected_figure_type_toolbar'],
        strokeWidth = json['stroke_width'].toDouble(),
        strokeCap = json['stroke_cap'],
        color = json['color'],
        points = WSScribbleAdd.fromJsonList(json['points']),
        paintingStyle = json['painting_style'],
        leftExtremity = json['left_extremity'].toDouble(),
        rightExtremity = json['right_extremity'].toDouble(),
        topExtremity = json['top_extremity'].toDouble(),
        bottomExtremity = json['bottom_extremity'].toDouble();
}
