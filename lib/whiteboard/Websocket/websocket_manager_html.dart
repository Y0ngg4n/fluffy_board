import 'package:fluffy_board/whiteboard/Websocket/websocket_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart';
import 'package:localstorage/localstorage.dart';

class WebsocketManagerHtml implements WebsocketManager {
  final LocalStorage settingsStorage = new LocalStorage('settings');
  OnWebsocketMessage onWebsocketMessage;

  late WebSocket channel;

  @override
  initializeConnection(String whiteboard, String authToken) async {
    channel = await connectWs(whiteboard, authToken);
    print("socket connection initialized");
    this.channel.onClose.listen((event) {
      onDisconnected(whiteboard, authToken);
    });
    startListener(whiteboard, authToken);
  }

  @override
  connectWs(String whiteboard, String authToken) async {
    WebSocket webSocket = WebSocket(
        (settingsStorage.getItem("WS_API_URL") ?? dotenv.env['WS_API_URL']!) + "/$whiteboard/$authToken");
    return webSocket;
  }

  @override
  sendDataToChannel(String key, String data) {
    channel.sendString(key + data);
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
    channel.onOpen.listen((event) {
      sendDataToChannel("connected-users#", "");
    });
    channel.onMessage.listen((event) {
      onWebsocketMessage(event.data);
    });
    channel.onClose.listen((event) {
      print("connecting aborted");
      if (!disconnect) initializeConnection(whiteboard, authToken);
    });
    channel.onError.listen((event) {
      print('Server error: $event');
      initializeConnection(whiteboard, authToken);
    });
  }

  WebsocketManagerHtml(this.onWebsocketMessage);

  @override
  startDisconnect() {
    channel.close();
  }
}

WebsocketManager getManager(OnWebsocketMessage onWebsocketMessage) => WebsocketManagerHtml(onWebsocketMessage);