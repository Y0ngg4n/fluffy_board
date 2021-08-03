import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:fluffy_board/whiteboard/whiteboard-data/draw_point.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/json_encodable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// Normal Websocket Type such as Adding and Updating Items.
abstract class JsonWebSocketType {
  static fromJsonList(List<dynamic> jsonList) {}
  JsonWebSocketType.fromJson(Map<String, dynamic> json);
  Map toJson();
}

/// Decoding Websocket Type. Used when recieving Data over the Websocket from the Server.
abstract class DecodeGetJsonWebSocketType {
  static fromJsonList(List<dynamic> jsonList) {}
  DecodeGetJsonWebSocketType.fromJson(Map<String, dynamic> json);
}

/// Decoding Websocket Types as List. Used when needed multiple Items.
abstract class DecodeGetJsonWebSocketTypeList {
  static fromJsonList(List<dynamic> jsonList) {}
}





