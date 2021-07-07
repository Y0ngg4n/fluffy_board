import 'dart:typed_data';

import 'WebsocketManager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class WebsocketManagerOther implements WebsocketManager {
  OnWebsocketMessage onWebsocketMessage;

  late WebSocket channel;

  @override
  initializeConnection(String whiteboard, String auth_token) async {
    channel = await connectWs(whiteboard, auth_token);
    print("socket connection initialized");
    this
        .channel
        .done
        .then((dynamic _) => onDisconnected(whiteboard, auth_token));
    startListener(whiteboard, auth_token);
  }

  @override
  connectWs(String whiteboard, String auth_token) async {
    WebSocket webSocket = await WebSocket.connect(
        dotenv.env['WS_API_URL']! + "/$whiteboard/$auth_token");
    return webSocket;
  }

  @override
  sendDataToChannel(String key, String data) {
    channel.add(key + data);
  }

  @override
  onDisconnected(String whiteboard, String auth_token) {
    if (!disconnect) initializeConnection(whiteboard, auth_token);
  }

  @override
  bool disconnect = false;

  @override
  setDisconnect(bool status) {
    disconnect = status;
  }

  @override
  startListener(String whiteboard, String auth_token) {
    print("starting listeners ...");
    this.channel.listen((streamData) {
      onWebsocketMessage(streamData);
    }, onDone: () {
      print("connecting aborted");
      if (!disconnect) initializeConnection(whiteboard, auth_token);
    }, onError: (e) {
      print('Server error: $e');
      initializeConnection(whiteboard, auth_token);
    });
  }

  WebsocketManagerOther(this.onWebsocketMessage);

  @override
  startDisconnect() {
    channel.close();
  }
}

WebsocketManagerOther getManager(OnWebsocketMessage onWebsocketMessage) =>
    WebsocketManagerOther(onWebsocketMessage);
