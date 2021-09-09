import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/dashboard/filemanager/whiteboard_data_manager.dart';
import 'package:localstorage/localstorage.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'file_manager_types.dart';

class WebDavManager {
  static final LocalStorage settingsStorage = new LocalStorage('settings');
  static final LocalStorage fileManagerStorageIndex =
  new LocalStorage('filemanager-index');
  static final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  static Timer? timer;
  static final String path = "/Fluffyboard/OfflineWhiteboards";

  static Future<webdav.Client?> connect() async {
    bool webDavEnabled = settingsStorage.getItem("WEB_DAV_ENABLED") ?? "";
    String webDavURL = settingsStorage.getItem("WEB_DAV_URL") ?? "";
    String webDavUsername = settingsStorage.getItem("WEB_DAV_USERNAME") ?? "";
    String webDavPassword = settingsStorage.getItem("WEB_DAV_PASSWORD") ?? "";
    if (!webDavEnabled || webDavURL.isEmpty) return null;
    print("Connecting to WebDav ...");
    webdav.Client client = webdav.newClient(
      webDavURL,
      user: webDavUsername,
      password: webDavPassword,
      debug: false,
    );
    // Set the public request headers
    client.setHeaders({'accept-charset': 'utf-8'});

    // Set the connection server timeout time in milliseconds.
    client.setConnectTimeout(1000000);

    // Set send data timeout time in milliseconds.
    client.setSendTimeout(1000000);

    // Set transfer data time in milliseconds.
    client.setReceiveTimeout(1000000);

    // Test whether the service can connect
    try {
      await client.ping();
    } catch (e) {
      print('Error: $e');
      return null;
    }
    print("Connected to WebDav");
    return client;
  }

  static startAutomatedUpload(
      OfflineWhiteboards offlineWhiteboards, Directories directories) {
    print("Starting automated webdav sync");
    String webDavSyncInterval =
        (settingsStorage.getItem("WEB_DAV_SYNC_INTERVAL") ?? 30).toString();
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(Duration(minutes: int.parse(webDavSyncInterval)),
        (timer) => uploadOfflineWhiteboards(offlineWhiteboards, directories));
  }

  static uploadOfflineWhiteboards(
      OfflineWhiteboards offlineWhiteboards, Directories directories) async {
    webdav.Client? client = await connect();
    if (client == null) return;
    print("Starting upload of offline Whiteboards");

    print("Creating Directory...");
    await client.mkdirAll(path);
    print("Created Directory");
    for (OfflineWhiteboard offlineWhiteboard in offlineWhiteboards.list) {
      print("Uploading " + offlineWhiteboard.name);
      Directory? parent;
      for (Directory directory in directories.list) {
        if (directory.id == offlineWhiteboard.directory) {
          parent = directory;
          break;
        }
      }
      List<String> directoryPath = [];
      if (parent != null) {
        directoryPath.add(parent.filename);
        createParentDirectory(parent, directories, directoryPath, path, client);
        print(directoryPath);
      }
      String finalPath = getFinalPath(directoryPath);
      print(path + "/" + finalPath + offlineWhiteboard.uuid + ".json");
      await client.write(
          path + "/" + finalPath + offlineWhiteboard.uuid + ".json",
          Uint8List.fromList(
              jsonEncode(offlineWhiteboard.toJSONEncodable()).codeUnits));
    }
    print("Uploaded offline Whiteboards");
  }

  static createParentDirectory(Directory directory, Directories directories,
      List<String> directoryPath, String path, webdav.Client client) {
    for (Directory dir in directories.list) {
      if (directory.parent == dir.id) {
        directoryPath.add(dir.filename);
        createParentDirectory(dir, directories, directoryPath, path, client);
        break;
      }
    }
    String finalPath = getFinalPath(directoryPath);
    if (finalPath.endsWith("/"))
      finalPath = finalPath.substring(0, finalPath.length - 1);
    client.mkdirAll(path + "/" + finalPath);
  }

  static getFinalPath(List<String> directoryPath) {
    String finalPath = "";
    for (String str in directoryPath.reversed.toList()) {
      finalPath += str + "/";
    }
    return finalPath;
  }

  static restoreFromWebDav() async{
    webdav.Client? client = await connect();
    if (client == null) return;
    var list = await client.readDir(path);
    Set<String> ids = await WhiteboardDataManager.getOfflineWhiteboardIds();
    for(var f in list){
      if(f.path!.endsWith(".json")){
        List<int> data = await client.read(f.path!);
        Uint8List uint8list = Uint8List.fromList(data);
        String s = new String.fromCharCodes(uint8list);
        OfflineWhiteboard offlineWhiteboard = await OfflineWhiteboard.fromJson(jsonDecode(s));
        await fileManagerStorage.setItem("offline_whiteboard-" + offlineWhiteboard.uuid,
            offlineWhiteboard.toJSONEncodable());
        ids.add(offlineWhiteboard.uuid);
      }
      print('${f.name} ${f.path}');
    }
    await fileManagerStorageIndex.setItem(
        "indexes", jsonEncode(ids.toList()));
  }
}
