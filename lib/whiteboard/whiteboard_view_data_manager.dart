import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fluffy_board/dashboard/filemanager/file_manager_types.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/figure_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/zoom.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'Websocket/websocket-types/ws_bookmark.dart';
import 'Websocket/websocket-types/ws_scribble.dart';
import 'Websocket/websocket-types/ws_textitem.dart';
import 'Websocket/websocket-types/ws_upload.dart';

typedef OnGetScribbleAdd = Function(Scribble);
typedef OnGetUploadAdd = Function(Upload);
typedef OnGetTextItemAdd = Function(TextItem);
typedef OnGetBookmark = Function(List<Bookmark>);

class WhiteboardViewDataManager {
  static final LocalStorage settingsStorage = new LocalStorage('settings');
  static final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  static final LocalStorage fileManagerStorage =
      new LocalStorage('filemanager');

  static Future getScribbles(String authToken, Whiteboard? whiteboard, ExtWhiteboard? extWhiteboard, OnGetScribbleAdd onGetScribbleAdd, ZoomOptions zoomOptions) async {
    http.Response scribbleResponse = await http.post(
        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                dotenv.env['REST_API_URL']!) +
            "/whiteboard/scribble/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + authToken,
        },
        body: jsonEncode({
          "whiteboard": (whiteboard == null)
              ? extWhiteboard!.original
              : whiteboard.id,
          "permission_id": whiteboard == null
              ? extWhiteboard!.permissionId
              : whiteboard.editId
        }));

    if (scribbleResponse.statusCode == 200) {
      List<DecodeGetScribble> decodedScribbles =
          DecodeGetScribbleList.fromJsonList(jsonDecode(scribbleResponse.body));
        for (DecodeGetScribble decodeGetScribble in decodedScribbles) {
          Scribble newScribble = new Scribble(
              decodeGetScribble.uuid,
              decodeGetScribble.strokeWidth,
              StrokeCap.values[decodeGetScribble.strokeCap],
              HexColor.fromHex(decodeGetScribble.color),
              decodeGetScribble.points,
              SelectedFigureTypeToolbar
                  .values[decodeGetScribble.selectedFigureTypeToolbar],
              PaintingStyle.values[decodeGetScribble.paintingStyle]);

          ScreenUtils.calculateScribbleBounds(newScribble);
          ScreenUtils.bakeScribble(newScribble, zoomOptions.scale);
          onGetScribbleAdd(newScribble);
      }
    }
  }

  static Future getUploads(String authToken, Whiteboard? whiteboard, ExtWhiteboard? extWhiteboard, OnGetUploadAdd onGetUploadAdd, ZoomOptions zoomOptions) async {
    http.Response uploadResponse = await http.post(
        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                dotenv.env['REST_API_URL']!) +
            "/whiteboard/upload/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + authToken,
        },
        body: jsonEncode({
          "whiteboard": whiteboard == null
              ? extWhiteboard!.original
              : whiteboard.id,
          "permission_id": whiteboard == null
              ? extWhiteboard!.permissionId
              : whiteboard.editId
        }));
    if (uploadResponse.statusCode == 200) {
      List<DecodeGetUpload> decodedUploads =
          DecodeGetUploadList.fromJsonList(jsonDecode(uploadResponse.body));
        for (DecodeGetUpload decodeGetUpload in decodedUploads) {
          // TODO: Fix image import .... For loop is not getting called
          Uint8List uint8list = Uint8List.fromList(decodeGetUpload.imageData);
          ui.decodeImageFromList(uint8list, (image) {
            onGetUploadAdd(new Upload(
                decodeGetUpload.uuid,
                UploadType.values[decodeGetUpload.uploadType],
                uint8list,
                new Offset(
                    decodeGetUpload.offsetDx, decodeGetUpload.offsetDy),
                image));
          });
        }
    }
  }

  static Future getTextItems(String authToken, Whiteboard? whiteboard, ExtWhiteboard? extWhiteboard, OnGetTextItemAdd onGetTextItemAdd) async {
    http.Response textItemResponse = await http.post(
        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                dotenv.env['REST_API_URL']!) +
            "/whiteboard/textitem/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + authToken,
        },
        body: jsonEncode({
          "whiteboard": whiteboard == null
              ? extWhiteboard!.original
              : whiteboard.id,
          "permission_id": whiteboard == null
              ? extWhiteboard!.permissionId
              : whiteboard.editId
        }));
    if (textItemResponse.statusCode == 200) {
      List<DecodeGetTextItem> decodeTextItems =
          DecodeGetTextItemList.fromJsonList(jsonDecode(textItemResponse.body));
        for (DecodeGetTextItem decodeGetTextItem in decodeTextItems) {
          onGetTextItemAdd(new TextItem(
              decodeGetTextItem.uuid,
              false,
              decodeGetTextItem.strokeWidth,
              decodeGetTextItem.maxWidth,
              decodeGetTextItem.maxHeight,
              HexColor.fromHex(decodeGetTextItem.color),
              decodeGetTextItem.contentText,
              new Offset(
                  decodeGetTextItem.offsetDx, decodeGetTextItem.offsetDy),
              decodeGetTextItem.rotation));
        }
    }
  }

  static Future getBookmarks(RefreshController? refreshController, String authToken, Whiteboard? whiteboard, ExtWhiteboard? extWhiteboard, OfflineWhiteboard? offlineWhiteboard, OnGetBookmark onGetBookmark) async {
    if (offlineWhiteboard != null) {
      onGetBookmark(offlineWhiteboard.bookmarks.list);
      if (refreshController != null) refreshController.refreshCompleted();
    } else {
      List<Bookmark> localBookmarks = [];
      http.Response bookmarkResponse = await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                  dotenv.env['REST_API_URL']!) +
              "/whiteboard/bookmark/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + authToken,
          },
          body: jsonEncode({
            "whiteboard": whiteboard == null
                ? extWhiteboard!.original
                : whiteboard.id,
            "permission_id": whiteboard == null
                ? extWhiteboard!.permissionId
                : whiteboard.editId
          }));
      if (bookmarkResponse.statusCode == 200) {
        List<DecodeGetBookmark> decodeBookmarks =
            DecodeGetBookmarkList.fromJsonList(
                jsonDecode(bookmarkResponse.body));
          for (DecodeGetBookmark decodeGetBookmark in decodeBookmarks) {
            localBookmarks.add(new Bookmark(
                decodeGetBookmark.uuid,
                decodeGetBookmark.name,
                new Offset(
                    decodeGetBookmark.offsetDx, decodeGetBookmark.offsetDy),
                decodeGetBookmark.scale));
          }
          onGetBookmark(localBookmarks);
          if (refreshController != null) refreshController.refreshCompleted();
      } else {
        if (refreshController != null) refreshController.refreshFailed();
      }
    }
  }
}
