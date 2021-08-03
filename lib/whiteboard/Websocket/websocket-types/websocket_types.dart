import 'dart:core';

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





