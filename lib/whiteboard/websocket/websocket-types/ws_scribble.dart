import 'dart:core';

import 'package:fluffy_board/whiteboard/websocket/websocket-types/websocket_types.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/draw_point.dart';
import 'package:uuid/uuid.dart';

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
      : uuid = json['uuid'] ?? Uuid().v4(),
        selectedFigureTypeToolbar = json['selected_figure_type_toolbar'] ?? 0,
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        strokeCap = json['stroke_cap'] ?? 0,
        color = json['color'] ?? "#000000",
        points = WSScribbleAdd.fromJsonList(json['points'] ?? []),
        paintingStyle = json['painting_style'] ?? 0;

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
      : uuid = json['uuid'] ?? Uuid().v4(),
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        strokeCap = json['stroke_cap'] ?? 0,
        color = json['color'] ?? "#000000",
        points = WSScribbleAdd.fromJsonList(json['points'] ?? []),
        paintingStyle = json['painting_style'] ?? 0,
        leftExtremity = (json['left_extremity'] ?? 0).toDouble(),
        rightExtremity = (json['right_extremity'] ?? 0).toDouble(),
        topExtremity = (json['top_extremity'] ?? 0).toDouble(),
        bottomExtremity = (json['bottom_extremity'] ?? 0).toDouble();

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
      : uuid = json['id'] ?? Uuid().v4(),
        selectedFigureTypeToolbar = json['selected_figure_type_toolbar'] ?? 0,
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        strokeCap = json['stroke_cap'] ?? 0,
        color = json['color'] ?? "#000000",
        points = WSScribbleAdd.fromJsonList(json['points'] ?? []),
        paintingStyle = json['painting_style'] ?? 0,
        leftExtremity = (json['left_extremity'] ?? 0).toDouble(),
        rightExtremity = (json['right_extremity'] ?? 0).toDouble(),
        topExtremity = (json['top_extremity'] ?? 0).toDouble(),
        bottomExtremity = (json['bottom_extremity'] ?? 0).toDouble();
}
