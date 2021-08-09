import 'package:fluffy_board/dashboard/filemanager/web_dav_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:localstorage/localstorage.dart';
import '../action_buttons.dart';
import 'package:uuid/uuid.dart';
import '../avatar_icon.dart';
import 'file_action_manager.dart';
import 'file_manager_types.dart';
import 'whiteboard_data_manager.dart';

class FileManager extends StatefulWidget {
  final String authToken;
  final String username;
  final String id;
  final bool online;

  FileManager(this.authToken, this.username, this.id, this.online);

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
  static const double fontSize = 25;
  static const double fileIconSize = 100;
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
        fileIconSize,
        widget.authToken,
        currentDirectory,
        _refreshController, (directory) {
      currentDirectory = directory!.id;
      currentDirectoryPath.add(directory);
    });
    FileActionManager.mapBreadCrumbs(
        context, breadCrumbItems, fontSize, widget.authToken, (directory) {
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
        fileIconSize,
        widget.authToken,
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
        fileIconSize,
        offlineWhiteboards,
        offlineWhiteboardIds,
        currentDirectory,
        widget.authToken,
        widget.id,
        widget.online,
        _refreshController);
    FileActionManager.mapOfflineWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        offlineWhiteboards,
        fileIconSize,
        widget.authToken,
        widget.id,
        widget.online,
        _refreshController,
        offlineWhiteboardIds);

    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              Text("Dashboard"),
              Expanded(
                child: ActionButtons(
                    widget.authToken,
                    currentDirectory,
                    _refreshController,
                    offlineWhiteboards,
                    offlineWhiteboardIds,
                    widget.online,
                    directories),
              ),
            ],
          ),
          actions: [AvatarIcon(widget.online)]),
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
                      widget.authToken,
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
                  if (widget.online)
                    WebDavManager.startAutomatedUpload(
                        await WhiteboardDataManager.getAllOfflineWhiteboards(
                            this.offlineWhiteboardIds),
                      await WhiteboardDataManager.getAllDirectories(widget.authToken)
                    );
                },
                child: GridView.extent(
                  maxCrossAxisExtent: 200,
                  children: directoryAndWhiteboardButtons,
                )))
      ])),
    );
  }
}
