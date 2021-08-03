import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'file_manager_types.dart';

class WebDavManager {
  static final LocalStorage settingsStorage = new LocalStorage('settings');
  static Timer? timer;

  static Future<webdav.Client?> connect() async {
    print("Connecting to WebDav ...");
    String webDavURL = settingsStorage.getItem("WEB_DAV_URL") ?? "";
    String webDavUsername = settingsStorage.getItem("WEB_DAV_USERNAME") ?? "";
    String webDavPassword = settingsStorage.getItem("WEB_DAV_PASSWORD") ?? "";
    if (webDavURL.isEmpty) return null;
    webdav.Client client = webdav.newClient(
      webDavURL,
      user: webDavUsername,
      password: webDavPassword,
      debug: true,
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

  static startAutomatedUpload(OfflineWhiteboards offlineWhiteboards) {
    print("Starting automated webdav sync");
    String webDavSyncInterval =
        settingsStorage.getItem("WEB_DAV_SYNC_INTERVAL") ?? 30;
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(Duration(minutes: int.parse(webDavSyncInterval)),
        (timer) => uploadOfflineWhiteboards(offlineWhiteboards));
  }

  static uploadOfflineWhiteboards(OfflineWhiteboards offlineWhiteboards) async {
    webdav.Client? client = await connect();
    if (client == null) return;
    print("Starting upload of offline Whiteboards");
    String path = "/Fluffyboard/OfflineWhiteboards";
    print("Creating Directory...");
    await client.mkdirAll(path);
    print("Created Directory");
    for (OfflineWhiteboard offlineWhiteboard in offlineWhiteboards.list) {
      print("Uploading " + offlineWhiteboard.name);
      await client.write(
          path + "/" + offlineWhiteboard.uuid + ".json",
          Uint8List.fromList(
              jsonEncode(offlineWhiteboard.toJSONEncodable()).codeUnits));
    }
    print("Uploaded offline Whiteboards");
  }
}
