import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/dashboard/filemanager/RenameFolder.dart';
import 'package:fluffy_board/dashboard/filemanager/RenameWhiteboard.dart';
import 'package:fluffy_board/dashboard/filemanager/ShareWhiteboard.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:localstorage/localstorage.dart';
import '../ActionButtons.dart';
import 'package:uuid/uuid.dart';

import 'DeleteManager.dart';
import 'FileActionManager.dart';
import 'FileManagerTypes.dart';
import 'RenameOfflineWhiteboard.dart';
import 'WhiteboardDataManager.dart';

class FileManager extends StatefulWidget {
  String auth_token;
  String username;
  String id;
  bool online;

  FileManager(this.auth_token, this.username, this.id, this.online);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  Directories directories = new Directories([]);
  Whiteboards whiteboards = new Whiteboards([]);
  ExtWhiteboards extWhiteboards = new ExtWhiteboards([]);
  OfflineWhiteboards offlineWhiteboards = new OfflineWhiteboards([]);
  Set<String> offlineWhiteboardIds = Set.of([]);
  String currentDirectory = "";
  List<Directory> currentDirectoryPath = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  double font_size = 25;
  double file_icon_size = 100;
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  var uuid = Uuid();
  final LocalStorage settingsStorage = new LocalStorage('settings');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> directoryAndWhiteboardButtons = [];
    List<BreadCrumbItem> breadCrumbItems = [];
    FileActionManager.mapDirectories(
        context,
        widget.online,
        directoryAndWhiteboardButtons,
        directories,
        file_icon_size,
        widget.auth_token,
        currentDirectory,
        _refreshController, (directory) {
      currentDirectory = directory!.id;
      currentDirectoryPath.add(directory);
    });
    FileActionManager.mapBreadCrumbs(context,
        breadCrumbItems, font_size, widget.auth_token, (directory) {
      if (directory == null) {
        currentDirectory = "";
        currentDirectoryPath.clear();
      } else {
        currentDirectory = directory.id;
      }
    }, _refreshController, currentDirectoryPath);
    FileActionManager.mapWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        whiteboards,
        file_icon_size,
        widget.auth_token,
        widget.id,
        widget.username,
        widget.online,
        currentDirectory,
        offlineWhiteboards,
        offlineWhiteboardIds,
        _refreshController);
    FileActionManager.mapExtWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        extWhiteboards,
        file_icon_size,
        offlineWhiteboards,
        offlineWhiteboardIds,
        currentDirectory,
        widget.auth_token,
        widget.id,
        widget.online,
        _refreshController);
    FileActionManager.mapOfflineWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        offlineWhiteboards,
        file_icon_size,
        widget.auth_token,
        widget.id,
        widget.online,
        _refreshController,
        offlineWhiteboardIds);

    return Container(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            BreadCrumb(
              items: breadCrumbItems,
              divider: Icon(Icons.chevron_right),
              overflow: WrapOverflow(
                keepLastDivider: false,
                direction: Axis.horizontal,
              ),
            ),
            ActionButtons(
                widget.auth_token,
                currentDirectory,
                _refreshController,
                offlineWhiteboards,
                offlineWhiteboardIds,
                widget.online,
                directories)
          ],
        ),
      ),
      Expanded(
          child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: () {
                WhiteboardDataManager.getDirectoriesAndWhiteboards(
                    widget.online,
                    currentDirectory,
                    widget.auth_token,
                    _refreshController,
                    directories,
                    whiteboards,
                    extWhiteboards,
                    offlineWhiteboardIds,
                    offlineWhiteboards, (directories,
                        whiteboards,
                        extWhiteboards,
                        offlineWhiteboardIds,
                        offlineWhiteboards) {
                  setState(() {
                    this.directories = directories;
                    this.whiteboards = whiteboards;
                    this.extWhiteboards = extWhiteboards;
                    this.offlineWhiteboardIds = offlineWhiteboardIds;
                    this.offlineWhiteboards = offlineWhiteboards;
                  });
                });
              },
              child: GridView.extent(
                maxCrossAxisExtent: 200,
                children: directoryAndWhiteboardButtons,
              )))
    ]));
  }
}
