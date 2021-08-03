import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

import '../overlays/Toolbar/FigureToolbar.dart';
import 'package:uuid/uuid.dart';

import 'json_encodable.dart';

class Bookmarks {
  List<Bookmark> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  Bookmarks.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(Bookmark.fromJson(entry));
    }
  }

  Bookmarks(this.list);
}

class Bookmark {
  String uuid;
  String name;
  ui.Offset offset;
  double scale;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['name'] = name;
    m['offset_dx'] = offset.dx;
    m['offset_dy'] = offset.dy;
    m['scale'] = scale;

    return m;
  }

  Bookmark.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        offset = new ui.Offset(json['offset_dx'].toDouble(), json['offset_dy'].toDouble()),
        scale = json['scale'].toDouble();

  Bookmark(this.uuid, this.name, this.offset, this.scale);

}

