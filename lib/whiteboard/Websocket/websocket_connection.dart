import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:fluffy_board/whiteboard/Websocket/websocket_manager.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/ws_bookmark.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/ws_scribble.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/ws_textitem.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/ws_upload.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/ws_user_move.dart';
import 'package:fluffy_board/whiteboard/appbar/connected_users.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/figure_toolbar.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:ui';

import '../whiteboard_view.dart';
import 'dart:ui' as ui;
import 'package:random_color/random_color.dart';


typedef OnScribbleAdd = Function(Scribble);
typedef OnScribbleUpdate = Function(Scribble);
typedef OnScribbleDelete = Function(String);

typedef OnUploadAdd = Function(Upload);
typedef OnUploadUpdate = Function(Upload);
typedef OnUploadImageDataUpdate = Function(Upload);
typedef OnUploadDelete = Function(String);

typedef OnTextItemAdd = Function(TextItem);
typedef OnTextItemUpdate = Function(TextItem);

typedef OnUserJoin = Function(ConnectedUser);
typedef OnUserMove = Function(ConnectedUserMove);

typedef OnBookmarkAdd = Function(Bookmark);
typedef OnBookmarkUpdate= Function(Bookmark);
typedef OnBookmarkDelete= Function(String);

class WebsocketConnection {
  static WebsocketConnection? _singleton;

  StreamController<String> streamController =
  new StreamController.broadcast(sync: true);

  String whiteboard;
  String authToken;
  bool disconnect = false;

  late WebsocketManager websocketManager;

  OnScribbleAdd onScribbleAdd;
  OnScribbleUpdate onScribbleUpdate;
  OnScribbleDelete onScribbleDelete;

  OnUploadAdd onUploadAdd;
  OnUploadUpdate onUploadUpdate;
  OnUploadImageDataUpdate onUploadImageDataUpdate;
  OnUploadDelete onUploadDelete;

  OnTextItemAdd onTextItemAdd;
  OnTextItemUpdate onTextItemUpdate;

  OnUserJoin onUserJoin;
  OnUserMove onUserMove;

  OnBookmarkAdd onBookmarkAdd;
  OnBookmarkUpdate onBookmarkUpdate;
  OnBookmarkDelete onBookmarkDelete;

  final RandomColor _randomColor = RandomColor();

  WebsocketConnection({
    required this.whiteboard,
    required this.authToken,
    required this.onScribbleAdd,
    required this.onScribbleUpdate,
    required this.onScribbleDelete,
    required this.onUploadAdd,
    required this.onUploadUpdate,
    required this.onUploadImageDataUpdate,
    required this.onUploadDelete,
    required this.onTextItemAdd,
    required this.onTextItemUpdate,
    required this.onUserJoin,
    required this.onUserMove,
    required this.onBookmarkAdd,
    required this.onBookmarkUpdate,
    required this.onBookmarkDelete
  });

  static WebsocketConnection getInstance({required String whiteboard,
    required String authToken,
    required Function(Scribble) onScribbleAdd,
    required Function(Scribble) onScribbleUpdate,
    required Function(String) onScribbleDelete,
    required Function(Upload) onUploadAdd,
    required Function(Upload) onUploadUpdate,
    required Function(Upload) onUploadImageDataUpdate,
    required Function(String) onUploadDelete,
    required Function(TextItem) onTextItemAdd,
    required Function(TextItem) onTextItemUpdate,
    required Function(ConnectedUser) onUserJoin,
    required Function(ConnectedUserMove) onUserMove,
    required Function(Bookmark) onBookmarkAdd,
    required Function(Bookmark) onBookmarkUpdate,
    required Function(String) onBookmarkDelete
  }) {
    if (_singleton == null) {
      _singleton = new WebsocketConnection(
          whiteboard: whiteboard,
          authToken: authToken,
          onScribbleAdd: onScribbleAdd,
          onScribbleUpdate: onScribbleUpdate,
          onScribbleDelete: onScribbleDelete,
          onUploadAdd: onUploadAdd,
          onUploadUpdate: onUploadUpdate,
          onUploadImageDataUpdate: onUploadImageDataUpdate,
          onUploadDelete: onUploadDelete,
          onTextItemAdd: onTextItemAdd,
          onTextItemUpdate: onTextItemUpdate,
          onUserJoin: onUserJoin,
        onUserMove: onUserMove,
        onBookmarkAdd: onBookmarkAdd,
        onBookmarkUpdate: onBookmarkUpdate,
        onBookmarkDelete: onBookmarkDelete
      );
      _singleton!.initWebSocketConnection(whiteboard, authToken);
    }
    return _singleton!;
  }

  void initWebSocketConnection(String whiteboard, String authToken) async {
    websocketManager =
    new WebsocketManager((streamData) => messageHandler(streamData));
    await websocketManager.initializeConnection(whiteboard, authToken);
    print("conecting...");
  }

  dispose() {
    websocketManager.disconnect = true;
    websocketManager.startDisconnect();
    streamController.close();
    _singleton = null;
  }

  messageHandler(dynamic streamData) {
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
        Upload newUpload = Upload(json.uuid, UploadType.values[json.uploadType],
            uint8list, new Offset(json.offsetDx, json.offsetDy), image);
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
          new Offset(json.offsetDx, json.offsetDy),
          null));
    } else if (message.startsWith(r"upload-image-data-update#")) {
      WSUploadImageDataUpdate json = WSUploadImageDataUpdate.fromJson(
          jsonDecode(message.replaceFirst(r"upload-image-data-update#", ""))
          as Map<String, dynamic>);
      Uint8List uint8list = Uint8List.fromList(json.imageData);
      ui.decodeImageFromList(uint8list, (image) {
        Upload newUpload =
        Upload(json.uuid, UploadType.Image, uint8list, Offset.zero, image);
        onUploadImageDataUpdate(newUpload);
      });
      onUploadImageDataUpdate(new Upload(json.uuid, UploadType.Image,
          Uint8List.fromList(List.empty()), Offset.zero, null));
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
          json.contentText,
          new Offset(json.offsetDx, json.offsetDy),
          json.rotation));
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
          json.contentText,
          new Offset(json.offsetDx, json.offsetDy),
          json.rotation));
    } else if (message.startsWith(r"user-join#")) {
      String newMessage = message.replaceFirst(r"user-join#", "");
      List<String> arguments = newMessage.split("#");
      onUserJoin(new ConnectedUser(arguments[0], arguments[1], _randomColor.randomColor(), Offset.zero, 1));
    }else if (message.startsWith(r"user-move#")) {
      WSUserMove json = WSUserMove.fromJson(
          jsonDecode(message.replaceFirst(r"user-move#", ""))
          as Map<String, dynamic>);
      onUserMove(new ConnectedUserMove(json.uuid, new Offset(json.offsetDx, json.offsetDy), json.scale));
    } else if (message.startsWith(r"bookmark-add#")) {
      print("On r bookmark add");
      WSBookmarkAdd json = WSBookmarkAdd.fromJson(
          jsonDecode(message.replaceFirst(r"bookmark-add#", ""))
          as Map<String, dynamic>);
      onBookmarkAdd(new Bookmark(json.uuid, json.name, new Offset(json.offsetDx, json.offsetDy), json.scale));
    }else if (message.startsWith(r"bookmark-update#")) {
      WSBookmarkUpdate json = WSBookmarkUpdate.fromJson(
          jsonDecode(message.replaceFirst(r"bookmark-update#", ""))
          as Map<String, dynamic>);
      onBookmarkUpdate(new Bookmark(json.uuid, json.name, new Offset(json.offsetDx, json.offsetDy), json.scale));
    }else if (message.startsWith(r"bookmark-delete#")) {
      WSBookmarkDelete json = WSBookmarkDelete.fromJson(
          jsonDecode(message.replaceFirst(r"bookmark-delete#", ""))
          as Map<String, dynamic>);
      onBookmarkDelete(json.uuid);
    }
  }

  sendDataToChannel(String key, String data) {
    websocketManager.sendDataToChannel(key, data);
  }

}
