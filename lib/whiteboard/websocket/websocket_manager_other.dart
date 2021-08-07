import 'websocket_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';

class WebsocketManagerOther implements WebsocketManager {
  OnWebsocketMessage onWebsocketMessage;
  final LocalStorage settingsStorage = new LocalStorage('settings');

  WebSocket? channel;

  @override
  initializeConnection(String whiteboard, String authToken) async {
    channel = await connectWs(whiteboard, authToken);
    print("socket connection initialized");
    this
        .channel!
        .done
        .then((dynamic _) => onDisconnected(whiteboard, authToken));
    startListener(whiteboard, authToken);
  }

  @override
  connectWs(String whiteboard, String authToken) async {
    WebSocket webSocket = await WebSocket.connect(
        (settingsStorage.getItem("WS_API_URL") ?? dotenv.env['WS_API_URL']!) +
            "/$whiteboard/$authToken");
    print("New Websocket");
    return webSocket;
  }

  @override
  sendDataToChannel(String key, String data) {
    if (channel != null) channel!.add(key + data);
  }

  @override
  onDisconnected(String whiteboard, String authToken) {
    if (!disconnect) initializeConnection(whiteboard, authToken);
  }

  @override
  bool disconnect = false;

  @override
  setDisconnect(bool status) {
    disconnect = status;
  }

  @override
  startListener(String whiteboard, String authToken) {
    print("starting listeners ...");
    sendDataToChannel("connected-users#", "");
    this.channel!.listen((streamData) {
      onWebsocketMessage(streamData);
    }, onDone: () {
      print("connecting aborted");
      if (!disconnect) initializeConnection(whiteboard, authToken);
    }, onError: (e) {
      print('Server error: $e');
      initializeConnection(whiteboard, authToken);
    });
  }

  WebsocketManagerOther(this.onWebsocketMessage);

  @override
  startDisconnect() {
    channel!.close();
  }
}

WebsocketManagerOther getManager(OnWebsocketMessage onWebsocketMessage) =>
    WebsocketManagerOther(onWebsocketMessage);
