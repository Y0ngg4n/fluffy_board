import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'file_manager_types.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DeleteManager {
  static final LocalStorage settingsStorage = new LocalStorage('settings');
  static final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  static final LocalStorage fileManagerStorage =
      new LocalStorage('filemanager');

  static deleteFolderDialog(
      BuildContext context,
      Directory directory,
      String auth_token,
      Directories directories,
      RefreshController _refreshController) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the folder?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                                dotenv.env['REST_API_URL']!) +
                            "/filemanager/directory/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + auth_token,
                        },
                        body: jsonEncode({
                          "id": directory.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Folder"),
                    ));
                    directories.list.remove(directory);
                    await fileManagerStorage.setItem(
                        "directories", directories.toJSONEncodable());
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Folder!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  static deleteWhiteboardDialog(BuildContext context, Whiteboard whiteboard, String auth_token,
      RefreshController _refreshController) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                                dotenv.env['REST_API_URL']!) +
                            "/filemanager/whiteboard/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + auth_token,
                        },
                        body: jsonEncode({
                          "id": whiteboard.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Whiteboard!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  static deleteExtWhiteboardDialog(
      BuildContext context, ExtWhiteboard whiteboard, String auth_token, RefreshController _refreshController) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                                dotenv.env['REST_API_URL']!) +
                            "/filemanager-ext/whiteboard/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + auth_token,
                        },
                        body: jsonEncode({
                          "id": whiteboard.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Whiteboard!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  static deleteOfflineWhiteboardDialog(
      BuildContext context, OfflineWhiteboard whiteboard, Set<String> offlineWhiteboardIds, String auth_token, RefreshController _refreshController) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    fileManagerStorage
                        .deleteItem("offline_whiteboard-" + whiteboard.uuid);
                    offlineWhiteboardIds.remove(whiteboard.uuid);
                    await fileManagerStorageIndex.setItem(
                        "indexes", jsonEncode(offlineWhiteboardIds.toList()));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }
}
