import 'dart:convert';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket-types/ws_bookmark.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket-types/ws_scribble.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket-types/ws_textitem.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket-types/ws_upload.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket-types/ws_user_move.dart';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';

class WebsocketSend {
  static Future sendCreateScribble(
      Scribble newScribble, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSScribbleAdd(
        newScribble.uuid,
        newScribble.selectedFigureTypeToolbar.index,
        newScribble.strokeWidth,
        newScribble.strokeCap.index,
        newScribble.color.toHex(),
        newScribble.points,
        newScribble.paintingStyle.index).toJson());
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-add#", data);
    }
  }

  static Future sendScribbleUpdate(
      Scribble newScribble, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSScribbleUpdate(
      newScribble.uuid,
      newScribble.strokeWidth,
      newScribble.strokeCap.index,
      newScribble.color.toHex(),
      newScribble.points,
      newScribble.paintingStyle.index,
      newScribble.leftExtremity,
      newScribble.rightExtremity,
      newScribble.topExtremity,
      newScribble.bottomExtremity,
    ).toJson());
    print(data);
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-update#", data);
    }
  }

  static Future sendScribbleDelete(
      Scribble deleteScribble, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSScribbleDelete(
      deleteScribble.uuid,
    ).toJson());
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-delete#", data);
    }
  }

  static Future sendUploadCreate(
      Upload upload, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSUploadAdd(
        upload.uuid,
        upload.uploadType.index,
        upload.offset.dx,
        upload.offset.dy,
        // List.generate(10, (index) => 0)
        upload.uint8List.toList()).toJson());
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("upload-add#", data);
    }
  }

  static Future sendUploadUpdate(
      Upload newUpload, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSUploadUpdate(
      newUpload.uuid,
      newUpload.offset.dx,
      newUpload.offset.dy,
    ).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-update#", data);
  }

  static Future sendUploadImageDataUpdate(
      Upload newUpload, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(
        WSUploadImageDataUpdate(newUpload.uuid, newUpload.uint8List).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-image-data-update#", data);
  }

  static Future sendUploadDelete(
      Upload newUpload, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSUploadDelete(
      newUpload.uuid,
    ).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-delete#", data);
  }

  static Future sendCreateTextItem(
      TextItem textItem, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSTextItemAdd(
        textItem.uuid,
        textItem.strokeWidth,
        textItem.maxWidth,
        textItem.maxHeight,
        textItem.color.toHex(),
        textItem.text,
        textItem.offset.dx,
        textItem.offset.dy,
        textItem.rotation).toJson());
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("textitem-add#", data);
    }
  }

  static Future sendUpdateTextItem(
      TextItem textItem, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSTextItemUpdate(
        textItem.uuid,
        textItem.strokeWidth,
        textItem.maxWidth,
        textItem.maxHeight,
        textItem.color.toHex(),
        textItem.text,
        textItem.offset.dx,
        textItem.offset.dy,
        textItem.rotation).toJson());
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("textitem-update#", data);
    }
  }

  static Future sendTextItemDelete(
      TextItem newTextItem, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSTextItemDelete(
      newTextItem.uuid,
    ).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("text-item-delete#", data);
  }

  static Future sendUserMove(ui.Offset offset, String id, double scale,
      WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSUserMove(id, offset.dx, offset.dy, scale).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("user-move#", data);
  }

  static Future sendUserCursorMove(ui.Offset offset, String id,
      WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSUserCursorMove(id, offset.dx, offset.dy).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("user-cursor-move#", data);
  }

  static Future sendBookmarkAdd(
      Bookmark newBookmark, WebsocketConnection? websocketConnection) async{
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel(
          "bookmark-add#", jsonEncode(newBookmark.toJSONEncodable()));
    }
  }

  static Future sendBookmarkUpdate(
      Bookmark newBookmark, WebsocketConnection? websocketConnection) async{
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel(
          "bookmark-update#", jsonEncode(newBookmark.toJSONEncodable()));
    }
  }


  static Future sendBookmarkDelete(
      Bookmark newBookmark, WebsocketConnection? websocketConnection) async{
    String data = jsonEncode(WSBookmarkDelete(
      newBookmark.uuid,
    ).toJson());
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("bookmark-delete#", data);
  }
}
