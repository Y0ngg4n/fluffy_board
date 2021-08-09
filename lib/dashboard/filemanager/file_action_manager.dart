import 'dart:convert';
import 'dart:typed_data';
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'delete_manager.dart';
import 'file_manager_types.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:uuid/uuid.dart';
import 'rename_folder.dart';
import 'rename_offline_whiteboard.dart';
import 'rename_whiteboard.dart';
import 'share_whiteboard.dart';
import 'whiteboard_data_manager.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnDirectorySwitch = Function(Directory?);

class FileActionManager {
  static final LocalStorage settingsStorage = new LocalStorage('settings');
  static final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  static final LocalStorage fileManagerStorage =
      new LocalStorage('filemanager');

  static var uuid = Uuid();

  static _showUploadError(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorUploadWhiteboard),
        backgroundColor: Colors.red));
  }

  static _showMoveError(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorMovingWhiteboard),
        backgroundColor: Colors.red));
  }

  static mapDirectories(
      BuildContext context,
      bool online,
      directoryButtons,
      Directories directories,
      double fileIconSize,
      String authToken,
      String currentDirectory,
      RefreshController _refreshController,
      OnDirectorySwitch onDirectorySwitch) {
    for (Directory directory in directories.list) {
      directoryButtons.add(DragTarget(
        onAccept: (data) async {
          await moveWhiteboard(context, data, directory.id, authToken, _refreshController);
        },
        builder: (context, candidateData, rejectedData) {
          return LongPressDraggable<Directory>(
            data: directory,
            feedback: Icon(Icons.folder_open_outlined, size: fileIconSize),
            child: (Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        InkWell(
                          child: Icon(Icons.folder_open_outlined,
                              size: fileIconSize),
                          onTap: () {
                            if(_refreshController.isRefresh) return;
                            onDirectorySwitch(directory);

                            _refreshController.requestRefresh();
                          },
                        ),
                        Text(
                          directory.filename,
                          // style: TextStyle(fontSize: file_font_size),
                        )
                      ],
                    )),
                    PopupMenuButton(
                      itemBuilder: (context) => online
                          ? [
                              PopupMenuItem(
                                  child: Text(AppLocalizations.of(context)!.renameFolder), value: 0),
                              PopupMenuItem(
                                  child: Text(AppLocalizations.of(context)!.deleteFolder), value: 1),
                            ]
                          : [
                              PopupMenuItem(
                                  child: Text(AppLocalizations.of(context)!.renameFolder), value: 0),
                            ],
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      RenameFolder(
                                          authToken,
                                          directory.id,
                                          currentDirectory,
                                          directory.filename,
                                          _refreshController),
                                ));
                            break;
                          case 1:
                            DeleteManager.deleteFolderDialog(context, directory,
                                authToken, directories, _refreshController);
                            break;
                        }
                      },
                    )
                  ],
                ),
              ],
            )),
          );
        },
      ));
    }
  }

  static mapBreadCrumbs(
      BuildContext context,
      breadCrumbItems,
      double fontSize,
      String authToken,
      OnDirectorySwitch onDirectorySwitch,
      RefreshController _refreshController,
      List<Directory> currentDirectoryPath) {
    breadCrumbItems.add(BreadCrumbItem(
        content: DragTarget(onAccept: (data) async {
          await moveWhiteboard(context, data, "", authToken, _refreshController);
        }, builder: (context, candidateData, rejectedData) {
          return Icon(
            Icons.home,
            size: fontSize,
          );
        }),
        onTap: () {
          onDirectorySwitch(null);
          _refreshController.requestRefresh();
        }));
    for (int i = 0; i < currentDirectoryPath.length; i++) {
      String filename = currentDirectoryPath[i].filename;
      String uuid = currentDirectoryPath[i].id;
      breadCrumbItems.add(BreadCrumbItem(
          content: DragTarget(
            onAccept: (data) async {
              await moveWhiteboard(context, data, uuid, authToken, _refreshController);
            },
            builder: (context, candidateData, rejectedData) {
              return Text(filename, style: TextStyle(fontSize: fontSize));
            },
          ),
          onTap: () {
            onDirectorySwitch(currentDirectoryPath[i]);

            currentDirectoryPath.removeRange(
                i + 1, currentDirectoryPath.length);
            _refreshController.requestRefresh();
          }));
    }
  }

  static mapWhiteboards(
      BuildContext context,
      whiteboardButtons,
      Whiteboards whiteboards,
      double fileIconSize,
      String authToken,
      String id,
      String username,
      bool online,
      String currentDirectory,
      OfflineWhiteboards offlineWhiteboards,
      Set<String> offlineWhiteboardIds,
      RefreshController _refreshController) {
    for (Whiteboard whiteboard in whiteboards.list) {
      whiteboardButtons.add(LongPressDraggable<Whiteboard>(
        data: whiteboard,
        feedback: Icon(Icons.assignment, size: fileIconSize),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.assignment, size: fileIconSize),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(whiteboard, null, null,
                                          authToken, id, online)));
                        },
                      ),
                      Text(
                        whiteboard.name,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.renameWhiteboard), value: 0),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.deleteWhiteboard), value: 1),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.shareWhiteboard), value: 2),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.downloadWhiteboard), value: 3),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  RenameWhiteboard(
                                      authToken,
                                      whiteboard.id,
                                      currentDirectory,
                                      whiteboard.name,
                                      _refreshController),
                            ));
                        break;
                      case 1:
                        DeleteManager.deleteWhiteboardDialog(context,
                            whiteboard, authToken, _refreshController);
                        break;
                      case 2:
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ShareWhiteboard(
                                      authToken,
                                      username,
                                      whiteboard.id,
                                      whiteboard.name,
                                      currentDirectory,
                                      whiteboard.viewId,
                                      whiteboard.editId),
                            ));
                        break;
                      case 3:
                        OfflineWhiteboard
                            offlineWhiteboard = new OfflineWhiteboard(
                                uuid.v4(),
                                currentDirectory,
                                whiteboard.name,
                                await WhiteboardDataManager.getUploads(
                                    whiteboard.id,
                                    whiteboard.editId,
                                    authToken),
                                await WhiteboardDataManager.getTextItems(
                                    whiteboard.id,
                                    whiteboard.editId,
                                    authToken),
                                await WhiteboardDataManager.getScribbles(
                                    whiteboard.id,
                                    whiteboard.editId,
                                    authToken),
                                await WhiteboardDataManager.getBookmarks(
                                    whiteboard.id,
                                    whiteboard.editId,
                                    authToken),
                          Offset.zero, 1
                        );
                        offlineWhiteboards.list.add(offlineWhiteboard);
                       await fileManagerStorage.setItem(
                            "offline_whiteboard-" + offlineWhiteboard.uuid,
                            offlineWhiteboard.toJSONEncodable());
                        for (OfflineWhiteboard offWhi
                            in offlineWhiteboards.list) {
                          offlineWhiteboardIds.add(offWhi.uuid);
                        }
                        await fileManagerStorageIndex.setItem("indexes",
                            jsonEncode(offlineWhiteboardIds.toList()));
                        _refreshController.requestRefresh();
                        break;
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ));
    }
  }

  static mapExtWhiteboards(
      BuildContext context,
      whiteboardButtons,
      ExtWhiteboards extWhiteboards,
      double fileIconSize,
      OfflineWhiteboards offlineWhiteboards,
      Set<String> offlineWhiteboardIds,
      String currentDirectory,
      String authToken,
      String id,
      bool online,
      RefreshController _refreshController) {
    for (ExtWhiteboard whiteboard in extWhiteboards.list) {
      whiteboardButtons.add(LongPressDraggable<ExtWhiteboard>(
        data: whiteboard,
        feedback: Icon(Icons.assignment_ind, size: fileIconSize),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.assignment_ind, size: fileIconSize),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(null, whiteboard, null,
                                          authToken, id, online)));
                        },
                      ),
                      Text(
                        whiteboard.name,
                        // style: TextStyle(fontSize: file_font_size),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.deleteWhiteboard), value: 0),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.downloadWhiteboard), value: 1)
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        DeleteManager.deleteExtWhiteboardDialog(context,
                            whiteboard, authToken, _refreshController);
                        break;
                      case 1:
                        OfflineWhiteboard offlineWhiteboard =
                            new OfflineWhiteboard(
                                uuid.v4(),
                                currentDirectory,
                                whiteboard.name,
                                await WhiteboardDataManager.getUploads(
                                    whiteboard.original,
                                    whiteboard.permissionId,
                                    authToken),
                                await WhiteboardDataManager.getTextItems(
                                    whiteboard.original,
                                    whiteboard.permissionId,
                                    authToken),
                                await WhiteboardDataManager.getScribbles(
                                    whiteboard.original,
                                    whiteboard.permissionId,
                                    authToken),
                                await WhiteboardDataManager.getBookmarks(
                                    whiteboard.original,
                                    whiteboard.permissionId,
                                    authToken), Offset.zero, 1);
                        offlineWhiteboards.list.add(offlineWhiteboard);
                        await fileManagerStorage.setItem(
                            "offline_whiteboard-" + offlineWhiteboard.uuid,
                            offlineWhiteboard.toJSONEncodable());
                        for (OfflineWhiteboard offWhi
                            in offlineWhiteboards.list) {
                          offlineWhiteboardIds.add(offWhi.uuid);
                        }
                        await fileManagerStorageIndex.setItem("indexes",
                            jsonEncode(offlineWhiteboardIds.toList()));
                        _refreshController.requestRefresh();
                        break;
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ));
    }
  }

  static mapOfflineWhiteboards(
      BuildContext context,
      whiteboardButtons,
      OfflineWhiteboards offlineWhiteboards,
      double fileIconSize,
      String authToken,
      String id,
      bool online,
      RefreshController _refreshController,
      Set<String> offlineWhiteboardIds) {
    print("Map: " + offlineWhiteboards.list.length.toString());
    for (OfflineWhiteboard whiteboard in offlineWhiteboards.list) {
      whiteboardButtons.add(LongPressDraggable<OfflineWhiteboard>(
        data: whiteboard,
        feedback:
            Icon(Icons.download_for_offline_outlined, size: fileIconSize),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.download_for_offline_outlined,
                            size: fileIconSize),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(
                                          null,
                                          null,
                                          whiteboard,
                                          authToken,
                                          id,
                                          online)));
                        },
                      ),
                      Text(whiteboard.name
                          // style: TextStyle(fontSize: file_font_size),
                          ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.renameWhiteboard), value: 0),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.deleteWhiteboard), value: 1),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.uploadWhiteboard), value: 2),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.exportWhiteboard), value: 3)
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    RenameOfflineWhiteboard(
                                        whiteboard, _refreshController)));
                        break;
                      case 1:
                        DeleteManager.deleteOfflineWhiteboardDialog(
                            context,
                            whiteboard,
                            offlineWhiteboardIds,
                            authToken,
                            _refreshController);
                        break;
                      case 2:
                        http.Response response = await http.post(
                            Uri.parse(
                                (settingsStorage.getItem("REST_API_URL") ??
                                        dotenv.env['REST_API_URL']!) +
                                    "/filemanager/whiteboard/create"),
                            headers: {
                              "content-type": "application/json",
                              "accept": "application/json",
                              'Authorization': 'Bearer ' + authToken,
                            },
                            body: jsonEncode({
                              'name': whiteboard.name,
                              'directory': whiteboard.directory,
                              'password': "",
                            }));
                        CreateWhiteboardResponse createWhiteboardResponse =
                            CreateWhiteboardResponse.fromJson(
                                jsonDecode(response.body));
                        if (response.statusCode == 200) {
                          whiteboard.uuid = createWhiteboardResponse.id;
                          http.Response response = await http.post(
                              Uri.parse(
                                  (settingsStorage.getItem("REST_API_URL") ??
                                          dotenv.env['REST_API_URL']!) +
                                      "/offline-whiteboard/import"),
                              headers: {
                                "content-type": "application/json",
                                "accept": "application/json",
                                'Authorization': 'Bearer ' + authToken,
                              },
                              body: jsonEncode(whiteboard.toJSONEncodable()));
                          if (response.statusCode == 200) {
                            print("Import Successfull");
                          } else {
                            _showUploadError(context);
                          }
                          _refreshController.requestRefresh();
                        } else {
                          _showUploadError(context);
                        }
                        break;
                      case 3:
                        await FileSaver.instance.saveFile(
                            "FluffyBoard-" + whiteboard.name,
                            Uint8List.fromList(
                                jsonEncode(whiteboard.toJSONEncodable())
                                    .codeUnits),
                            "json");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.downloadedWhiteboardDownloadsFolder),
                            backgroundColor: Colors.green));
                        break;
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ));
    }
  }

  static moveWhiteboard(BuildContext context, dynamic data, String directoryUuid, String authToken, RefreshController _refreshController) async {
    if (data is Whiteboard) {
      Whiteboard whiteboard = data;
      whiteboard.parent = directoryUuid;
      http.Response response = await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                  dotenv.env['REST_API_URL']!) +
              "/filemanager/whiteboard/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + authToken,
          },
          body: jsonEncode({
            'id': whiteboard.id,
            'directory': directoryUuid,
          }));
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError(context);
      }
    } else if (data is ExtWhiteboard) {
      ExtWhiteboard whiteboard = data;
      whiteboard.directory = directoryUuid;
      http.Response response = await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                  dotenv.env['REST_API_URL']!) +
              "/filemanager-ext/whiteboard/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + authToken,
          },
          body: jsonEncode({
            'id': whiteboard.id,
            'directory': directoryUuid,
          }));
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError(context);
      }
    } else if (data is OfflineWhiteboard) {
      OfflineWhiteboard whiteboard = data;
      whiteboard.directory = directoryUuid;
      await fileManagerStorage.setItem("offline_whiteboard-" + whiteboard.uuid,
          whiteboard.toJSONEncodable());
      _refreshController.requestRefresh();
    } else if (data is Directory) {
      Directory directory = data;
      if (directory.id == directoryUuid) return;
      http.Response response = await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                  dotenv.env['REST_API_URL']!) +
              "/filemanager/directory/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + authToken,
          },
          body: jsonEncode({
            'id': directory.id,
            'parent': directoryUuid,
          }));
      directory.id = directoryUuid;
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError(context);
      }
    }
  }
}
