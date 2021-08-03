import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluffy_board/dashboard/filemanager/rename_folder.dart';
import 'package:fluffy_board/dashboard/filemanager/rename_whiteboard.dart';
import 'package:fluffy_board/dashboard/filemanager/share_whiteboard.dart';
import 'package:fluffy_board/dashboard/filemanager/web_dav_manager.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/json_encodable.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/figure_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:localstorage/localstorage.dart';
import '../action_buttons.dart';
import 'package:uuid/uuid.dart';
import '../avatar_icon.dart';
import 'delete_manager.dart';
import 'file_action_manager.dart';
import 'file_manager_types.dart';
import 'rename_offline_whiteboard.dart';
import 'whiteboard_data_manager.dart';

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
    FileActionManager.mapBreadCrumbs(
        context, breadCrumbItems, font_size, widget.auth_token, (directory) {
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

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), actions: [
        ActionButtons(
            widget.auth_token,
            currentDirectory,
            _refreshController,
            offlineWhiteboards,
            offlineWhiteboardIds,
            widget.online,
            directories),
        AvatarIcon(widget.online)
      ]),
      body: Container(
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
            ],
          ),
        ),
        Divider(),
        Expanded(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: () async {
                 await WhiteboardDataManager.getDirectoriesAndWhiteboards(
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
                  if (widget.online) WebDavManager.startAutomatedUpload(offlineWhiteboards);
                },
                child: GridView.extent(
                  maxCrossAxisExtent: 200,
                  children: directoryAndWhiteboardButtons,
                )))
      ])),
    );
  }
}
