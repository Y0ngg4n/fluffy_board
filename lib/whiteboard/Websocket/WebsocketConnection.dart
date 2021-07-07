import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:fluffy_board/whiteboard/Websocket/WebsocketManager.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:ui';

import '../DrawPoint.dart';
import '../WhiteboardView.dart';
import 'WebsocketTypes.dart';
import 'dart:ui' as ui;

typedef OnScribbleAdd = Function(Scribble);
typedef OnScribbleUpdate = Function(Scribble);
typedef OnScribbleDelete = Function(String);

typedef OnUploadAdd = Function(Upload);
typedef OnUploadUpdate = Function(Upload);
typedef OnUploadDelete = Function(String);

typedef OnTextItemAdd = Function(TextItem);
typedef OnTextItemUpdate = Function(TextItem);

class WebsocketConnection {
  static WebsocketConnection? _singleton = null;

  StreamController<String> streamController =
      new StreamController.broadcast(sync: true);

  String whiteboard;
  String auth_token;
  bool disconnect = false;

  late WebsocketManager websocketManager;

  OnScribbleAdd onScribbleAdd;
  OnScribbleUpdate onScribbleUpdate;
  OnScribbleDelete onScribbleDelete;

  OnUploadAdd onUploadAdd;
  OnUploadUpdate onUploadUpdate;
  OnUploadDelete onUploadDelete;

  OnTextItemAdd onTextItemAdd;
  OnTextItemUpdate onTextItemUpdate;

  WebsocketConnection({
    required this.whiteboard,
    required this.auth_token,
    required this.onScribbleAdd,
    required this.onScribbleUpdate,
    required this.onScribbleDelete,
    required this.onUploadAdd,
    required this.onUploadUpdate,
    required this.onUploadDelete,
    required this.onTextItemAdd,
    required this.onTextItemUpdate,
  });

  static WebsocketConnection getInstance(
      {required String whiteboard,
      required String auth_token,
      required Function(Scribble) onScribbleAdd,
      required Function(Scribble) onScribbleUpdate,
      required Function(String) onScribbleDelete,
      required Function(Upload) onUploadAdd,
      required Function(Upload) onUploadUpdate,
      required Function(String) onUploadDelete,
      required Function(TextItem) onTextItemAdd,
      required Function(TextItem) onTextItemUpdate}) {
    if (_singleton == null) {
      _singleton = new WebsocketConnection(
          whiteboard: whiteboard,
          auth_token: auth_token,
          onScribbleAdd: onScribbleAdd,
          onScribbleUpdate: onScribbleUpdate,
          onScribbleDelete: onScribbleDelete,
          onUploadAdd: onUploadAdd,
          onUploadUpdate: onUploadUpdate,
          onUploadDelete: onUploadDelete,
          onTextItemAdd: onTextItemAdd,
          onTextItemUpdate: onTextItemUpdate);
      _singleton!.initWebSocketConnection(whiteboard, auth_token);
    }
    ;
    return _singleton!;
  }

  void initWebSocketConnection(String whiteboard, String auth_token) async{
    websocketManager = new WebsocketManager((streamData) => messageHandler(streamData));
    websocketManager.initializeConnection(whiteboard, auth_token);
    print("conecting...");
  }
  dispose() {
    websocketManager.disconnect = true;
    websocketManager.startDisconnect();
    _singleton = null;
  }

  messageHandler(dynamic streamData){
    String message = streamData;
    if (message.startsWith(r"scribble-add#")) {
      WSScribbleAdd json = WSScribbleAdd.fromJson(
          jsonDecode(message.replaceFirst(r"scribble-add#", ""))
          as Map<String, dynamic>);
      Scribble newScribble = Scribble(
          json.uuid,
          json.strokeWidth,
          StrokeCap.values[json.strokeCap],
          HexColor.fromHex(json.color),
          json.points,
          SelectedFigureTypeToolbar.values[json.selectedFigureTypeToolbar],
          PaintingStyle.values[json.paintingStyle]);
      onScribbleAdd(newScribble);
    } else if (message.startsWith(r"scribble-update#")) {
      WSScribbleUpdate json = WSScribbleUpdate.fromJson(
          jsonDecode(message.replaceFirst(r"scribble-update#", ""))
          as Map<String, dynamic>);
      Scribble newScribble = Scribble(
          json.uuid,
          json.strokeWidth,
          StrokeCap.values[json.strokeCap],
          HexColor.fromHex(json.color),
          json.points,
          SelectedFigureTypeToolbar.none,
          PaintingStyle.values[json.paintingStyle]);
      onScribbleUpdate(newScribble);
    } else if (message.startsWith(r"scribble-delete#")) {
      WSScribbleDelete json = WSScribbleDelete.fromJson(
          jsonDecode(message.replaceFirst(r"scribble-delete#", ""))
          as Map<String, dynamic>);
      onScribbleDelete(json.uuid);
    } else if (message.startsWith(r"upload-add#")) {
      print("Upload add");
      WSUploadAdd json = WSUploadAdd.fromJson(
          jsonDecode(message.replaceFirst(r"upload-add#", ""))
          as Map<String, dynamic>);
      Uint8List uint8list = Uint8List.fromList(json.imageData);
      ui.decodeImageFromList(uint8list, (image) {
        Upload newUpload = Upload(
            json.uuid,
            UploadType.values[json.uploadType],
            uint8list,
            new Offset(json.offset_dx, json.offset_dy),
            image);
        onUploadAdd(newUpload);
      });
    } else if (message.startsWith(r"upload-update#")) {
      WSUploadUpdate json = WSUploadUpdate.fromJson(
          jsonDecode(message.replaceFirst(r"upload-update#", ""))
          as Map<String, dynamic>);
      onUploadUpdate(new Upload(
          json.uuid,
          UploadType.Image,
          Uint8List.fromList(List.empty()),
          new Offset(json.offset_dx, json.offset_dy),
          null));
    } else if (message.startsWith(r"upload-delete#")) {
      WSUploadDelete json = WSUploadDelete.fromJson(
          jsonDecode(message.replaceFirst(r"upload-delete#", ""))
          as Map<String, dynamic>);
      onUploadDelete(json.uuid);
    } else if (message.startsWith(r"textitem-add#")) {
      WSTextItemAdd json = WSTextItemAdd.fromJson(
          jsonDecode(message.replaceFirst(r"textitem-add#", ""))
          as Map<String, dynamic>);
      onTextItemAdd(new TextItem(
          json.uuid,
          false,
          json.strokeWidth,
          json.maxWidth,
          json.maxHeight,
          HexColor.fromHex(json.color),
          json.content_text,
          new Offset(json.offset_dx, json.offset_dy)));
    } else if (message.startsWith(r"textitem-update#")) {
      WSTextItemUpdate json = WSTextItemUpdate.fromJson(
          jsonDecode(message.replaceFirst(r"textitem-update#", ""))
          as Map<String, dynamic>);
      onTextItemUpdate(new TextItem(
          json.uuid,
          false,
          json.strokeWidth,
          json.maxWidth,
          json.maxHeight,
          HexColor.fromHex(json.color),
          json.content_text,
          new Offset(json.offset_dx, json.offset_dy)));
    }
  }

  sendDataToChannel(String key, String data) {
    websocketManager.sendDataToChannel(key, data);
  }
}
