
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/whiteboard/Websocket/WebsocketManager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart';

class WebsocketManagerHtml implements WebsocketManager {

  OnWebsocketMessage onWebsocketMessage;

  late WebSocket channel;

  @override
  initializeConnection(String whiteboard, String auth_token) async {
    channel = await connectWs(whiteboard, auth_token);
    print("socket connection initialized");
    this.channel.onClose.listen((event) {
      onDisconnected(whiteboard, auth_token);
    });
    startListener(whiteboard, auth_token);
  }

  @override
  connectWs(String whiteboard, String auth_token) async {
    WebSocket webSocket = WebSocket(
        dotenv.env['WS_API_URL']! + "/$whiteboard/$auth_token");
    return webSocket;
  }

  @override
  sendDataToChannel(String key, String data) {
    channel.sendString(key + data);
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
    channel.onMessage.listen((event) {
      onWebsocketMessage(event.data);
    });
    channel.onClose.listen((event) {
      print("connecting aborted");
      if (!disconnect) initializeConnection(whiteboard, auth_token);
    });
    channel.onError.listen((event) {
      print('Server error: $event');
      initializeConnection(whiteboard, auth_token);
    });
  }

  WebsocketManagerHtml(this.onWebsocketMessage);

  @override
  startDisconnect() {
    channel.close();
  }
}

WebsocketManager getManager(OnWebsocketMessage onWebsocketMessage) => WebsocketManagerHtml(onWebsocketMessage);