import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:flutter/material.dart';

import '../overlays/Toolbar/figure_toolbar.dart';
import 'package:uuid/uuid.dart';

import 'json_encodable.dart';

class TextItems {
  List<TextItem> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  TextItems.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(TextItem.fromJson(entry));
    }
  }

  TextItems(this.list);
}

class TextItem {
  String uuid;
  bool editing;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  ui.Color color;
  String text;
  ui.Offset offset;
  double rotation;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['stroke_width'] = strokeWidth;
    m['max_width'] = maxWidth;
    m['max_height'] = maxHeight;
    m['color'] = color.toHex();
    m['text'] = text;
    m['offset_dx'] = offset.dx;
    m['offset_dy'] = offset.dy;
    m['rotation'] = rotation;

    return m;
  }

  TextItem.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        editing = false,
        strokeWidth = json['stroke_width'],
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = HexColor.fromHex(json['color']),
        text = json['text'],
        offset = new ui.Offset(json['offset_dx'], json['offset_dy']),
        rotation = json['rotation'];

  TextItem(this.uuid, this.editing, this.strokeWidth, this.maxWidth,
      this.maxHeight, this.color, this.text, this.offset, this.rotation);
}