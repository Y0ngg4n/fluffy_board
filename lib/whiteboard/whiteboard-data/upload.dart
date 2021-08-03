import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

import '../overlays/Toolbar/FigureToolbar.dart';
import 'package:uuid/uuid.dart';

import 'json_encodable.dart';

enum UploadType {
  Image,
  PDF,
}

class Uploads implements JsonEncodable {
  List<Upload> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJson();
    }).toList();
  }

  static Future<Uploads> fromJson(List<dynamic> json) async {
    Uploads uploads = new Uploads([]);
    for (dynamic entry in json) {
      Upload upload = Upload.fromJson(entry.cast<String, dynamic>());
      final ui.Codec codec = await PaintingBinding.instance!
          .instantiateImageCodec(upload.uint8List);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      upload.image = frameInfo.image;
      uploads.list.add(upload);
    }
    return uploads;
  }

  Uploads(this.list);
}

class Upload {
  String uuid;
  UploadType uploadType;
  ui.Offset offset;

  Uint8List uint8List;
  ui.Image? image;

  Upload.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        uploadType = UploadType.values[json['upload_type']],
        offset = new ui.Offset(json['offset_dx'], json['offset_dy']),
        uint8List = Uint8List.fromList(json['uint8list'].cast<int>()),
        image = null;

  Map toJson() {
    List<int> list = uint8List.toList();
    return {
      'uuid': uuid,
      'upload_type': uploadType.index,
      'offset_dx': offset.dx,
      'offset_dy': offset.dy,
      'uint8list': list
    };
  }

  Upload(this.uuid, this.uploadType, this.uint8List, this.offset, this.image);
}