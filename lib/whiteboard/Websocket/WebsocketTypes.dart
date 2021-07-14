import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

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

class DecodeGetScribble {
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

class DecodeGetScribbleList {
  static List<DecodeGetScribble> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetScribble> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetScribble.fromJson(json));
    }
    return points;
  }
}

class WSUploadAdd {
  String uuid;
  int uploadType;
  double offset_dx;
  double offset_dy;
  List<int> imageData;

  WSUploadAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        uploadType = json['upload_type'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        imageData = json['image_data'].cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'upload_type': uploadType,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'image_data': imageData,
    };
  }

  WSUploadAdd(this.uuid, this.uploadType, this.offset_dx, this.offset_dy,
      this.imageData);
}

class WSUploadUpdate {
  String uuid;
  double offset_dx;
  double offset_dy;

  WSUploadUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
    };
  }

  WSUploadUpdate(this.uuid, this.offset_dx, this.offset_dy);
}

class WSUploadImageDataUpdate {
  String uuid;
  List<int> imageData;

  WSUploadImageDataUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        imageData = json['image_data'].cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'image_data': imageData,
    };
  }

  WSUploadImageDataUpdate(this.uuid, this.imageData);
}

class WSUploadDelete {
  String uuid;

  WSUploadDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSUploadDelete(this.uuid);
}

class DecodeGetUpload {
  String uuid;
  int uploadType;
  double offset_dx;
  double offset_dy;

  List<int> imageData;

  DecodeGetUpload.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        uploadType = json['upload_type'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        imageData = json['image_data'].cast<int>();
}

class DecodeGetUploadList {
  static List<DecodeGetUpload> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetUpload> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetUpload.fromJson(json));
    }
    return points;
  }
}

class WSTextItemAdd {
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String content_text;
  double offset_dx;
  double offset_dy;
  double rotation;

  WSTextItemAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        content_text = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': content_text,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'rotation': rotation
    };
  }

  WSTextItemAdd(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.content_text,
      this.offset_dx,
      this.offset_dy,
      this.rotation);
}

class WSTextItemUpdate {
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String content_text;
  double offset_dx;
  double offset_dy;
  double rotation;

  WSTextItemUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        content_text = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': content_text,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'rotation': rotation
    };
  }

  WSTextItemUpdate(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.content_text,
      this.offset_dx,
      this.offset_dy,
      this.rotation);
}

class DecodeGetTextItem {
  String uuid;
  double strokeWidth;
  int maxHeight;
  int maxWidth;
  String color;
  String contentText;
  double offset_dx;
  double offset_dy;
  double rotation;

  DecodeGetTextItem.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxHeight = json['max_height'],
        maxWidth = json['max_width'],
        color = json['color'],
        contentText = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();
}

class DecodeGetTextItemList {
  static List<DecodeGetTextItem> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetTextItem> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetTextItem.fromJson(json));
    }
    return points;
  }
}

class WSUserMove {
  String uuid;
  double offset_dx;
  double offset_dy;
  double scale;

  WSUserMove.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'scale': scale
    };
  }

  WSUserMove(this.uuid, this.offset_dx, this.offset_dy, this.scale);
}
class DecodeGetBookmark{
  String uuid;
  String name;
  double offset_dx;
  double offset_dy;
  double scale;

  DecodeGetBookmark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        name = json['name'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();
}

class DecodeGetBookmarkList {
  static List<DecodeGetBookmark> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetBookmark> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetBookmark.fromJson(json));
    }
    return points;
  }
}

class WSBookmarkAdd {
  String uuid;
  String name;
  double offset_dx;
  double offset_dy;
  double scale;

  WSBookmarkAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'scale': scale,
    };
  }

  WSBookmarkAdd(
      this.uuid, this.name, this.offset_dx, this.offset_dy, this.scale);
}

class WSBookmarkDelete {
  String uuid;

  WSBookmarkDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSBookmarkDelete(this.uuid);
}