import 'dart:convert';

import 'package:fluffy_board/dashboard/filemanager/AddFolder.dart';
import 'package:fluffy_board/dashboard/filemanager/AddOfflineWhiteboard.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'filemanager/AddExtWhiteboard.dart';
import 'filemanager/AddWhiteboard.dart';
import 'filemanager/FileManager.dart';

class ActionButtons extends StatefulWidget {
  String auth_token, parent;
  RefreshController _refreshController;
  OfflineWhiteboards offlineWhiteboards;
  Set<String> offlineWhiteboardIds;
  bool online;
  Directories directories;

  ActionButtons(this.auth_token, this.parent, this._refreshController,
      this.offlineWhiteboards, this.offlineWhiteboardIds, this.online, this.directories);

  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        widget.online
            ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(
                    onPressed: _createWhiteboard,
                    child: Text("Create Whiteboard")))
            : Container(),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ElevatedButton(
                onPressed: _createOfflineWhiteboard,
                child: Text("Create Offline Whiteboard"))),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ElevatedButton(
                onPressed: _createFolder, child: Text("Create Folder"))),
        widget.online
            ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(
                    onPressed: _collabOnWhiteboard,
                    child: Text("Collab on Whiteboard")))
            : Container(),
        widget.online
            ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(
                    onPressed: _importWhiteboard,
                    child: Text("Import Whiteboard")))
            : Container(),
      ],
    );
  }

  _createFolder() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AddFolder(
            widget.auth_token, widget.parent, widget._refreshController, widget.directories, widget.online),
      ),
    );
  }

  _createWhiteboard() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AddWhiteboard(
            widget.auth_token, widget.parent, widget._refreshController),
      ),
    );
  }

  _createOfflineWhiteboard() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AddOfflineWhiteboard(
            widget.auth_token,
            widget.parent,
            widget._refreshController,
            widget.offlineWhiteboards,
            widget.offlineWhiteboardIds),
      ),
    );
  }

  _collabOnWhiteboard() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AddExtWhiteboard(
            widget.auth_token, widget.parent, widget._refreshController),
      ),
    );
  }

  _importWhiteboard() async {
    FilePickerCross result = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom, fileExtension: 'json');
    await fileManagerStorage.ready;
    await fileManagerStorageIndex.ready;
    String json = new String.fromCharCodes(result.toUint8List());
    OfflineWhiteboard offlineWhiteboard =
        await OfflineWhiteboard.fromJson(jsonDecode(json));
    fileManagerStorage.setItem("offline_whiteboard-" + offlineWhiteboard.uuid,
        offlineWhiteboard.toJSONEncodable());
    Set<String> offlineWhiteboardIds = Set.of([]);
    try {
      offlineWhiteboardIds = Set.of(
          jsonDecode(fileManagerStorageIndex.getItem("indexes"))
                  .cast<String>() ?? []);
    } catch (ignore) {
      offlineWhiteboardIds = Set.of([]);
    }
    offlineWhiteboardIds.add(offlineWhiteboard.uuid);
    fileManagerStorageIndex.setItem(
        "indexes", jsonEncode(offlineWhiteboardIds.toList()));
    widget._refreshController.requestRefresh();
  }
}
