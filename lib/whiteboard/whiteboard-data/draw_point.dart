import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

import '../overlays/Toolbar/FigureToolbar.dart';
import 'package:uuid/uuid.dart';

import 'json_encodable.dart';

class DrawPoints  implements JsonEncodable{
  List<DrawPoint> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  DrawPoints.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(DrawPoint.fromJson(entry.cast<String, dynamic>()));
    }
  }

  DrawPoints(this.list);
}

class DrawPoint extends ui.Offset implements JsonEncodable{
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }

  DrawPoint.of(ui.Offset offset) : super(offset.dx, offset.dy);

  DrawPoint.fromJson(Map<String, dynamic> json)
      : super(json['dx'].toDouble(), json['dy'].toDouble());

  Map toJSONEncodable() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }
}
