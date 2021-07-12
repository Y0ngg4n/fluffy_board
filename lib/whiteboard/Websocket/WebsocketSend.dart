import 'dart:convert';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';

import '../DrawPoint.dart';
import 'WebsocketTypes.dart';

class WebsocketSend {
  static sendCreateScribble(
      Scribble newScribble, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSScribbleAdd(
        newScribble.uuid,
        newScribble.selectedFigureTypeToolbar.index,
        newScribble.strokeWidth,
        newScribble.strokeCap.index,
        newScribble.color.toHex(),
        newScribble.points,
        newScribble.paintingStyle.index));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-add#", data);
    }
  }

  static sendScribbleUpdate(
      Scribble newScribble, WebsocketConnection? websocketConnection) {
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
    ));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-update#", data);
    }
  }

  static sendScribbleDelete(
      Scribble deleteScribble, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSScribbleDelete(
      deleteScribble.uuid,
    ));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("scribble-delete#", data);
    }
  }

  static sendUploadCreate(
      Upload upload, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSUploadAdd(
        upload.uuid,
        upload.uploadType.index,
        upload.offset.dx,
        upload.offset.dy,
        // List.generate(10, (index) => 0)
        upload.uint8List.toList()));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("upload-add#", data);
    }
  }

  static sendUploadUpdate(
      Upload newUpload, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSUploadUpdate(
      newUpload.uuid,
      newUpload.offset.dx,
      newUpload.offset.dy,
    ));
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-update#", data);
  }

  static sendUploadImageDataUpdate(
      Upload newUpload, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(
        WSUploadImageDataUpdate(newUpload.uuid, newUpload.uint8List));
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-image-data-update#", data);
  }

  static sendUploadDelete(
      Upload newUpload, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSUploadDelete(
      newUpload.uuid,
    ));
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("upload-delete#", data);
  }

  static sendCreateTextItem(
      TextItem textItem, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSTextItemAdd(
        textItem.uuid,
        textItem.strokeWidth,
        textItem.maxWidth,
        textItem.maxHeight,
        textItem.color.toHex(),
        textItem.text,
        textItem.offset.dx,
        textItem.offset.dy,
        textItem.rotation));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("textitem-add#", data);
    }
  }

  static sendUpdateTextItem(
      TextItem textItem, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSTextItemUpdate(
        textItem.uuid,
        textItem.strokeWidth,
        textItem.maxWidth,
        textItem.maxHeight,
        textItem.color.toHex(),
        textItem.text,
        textItem.offset.dx,
        textItem.offset.dy,
        textItem.rotation));
    if (websocketConnection != null) {
      websocketConnection.sendDataToChannel("textitem-update#", data);
    }
  }

  static sendTextItemDelete(
      TextItem newTextItem, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSScribbleDelete(
      newTextItem.uuid,
    ));
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("text-item-delete#", data);
  }

  static sendUserMove(
      ui.Offset offset, String id, double scale, WebsocketConnection? websocketConnection) {
    String data = jsonEncode(WSUserMove(
      id,
      offset.dx,
      offset.dy,
      scale
    ));
    if (websocketConnection != null)
      websocketConnection.sendDataToChannel("user-move#", data);
  }
}
