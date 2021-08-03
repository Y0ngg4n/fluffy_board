import 'dart:typed_data';

import 'websocket_manager_stub.dart'
if (dart.library.io) 'websocket_manager_other.dart'
if (dart.library.html) 'websocket_manager_html.dart';

typedef OnWebsocketMessage = Function(dynamic streamData);

abstract class WebsocketManager {

  bool disconnect = false;

  initializeConnection(String whiteboard, String auth_token);

  connectWs(String whiteboard, String auth_token);

  onDisconnected(String whiteboard, String auth_token);

  sendDataToChannel(String key, String data);

  setDisconnect(bool status);

  startListener(String whiteboard, String auth_token);

  startDisconnect();

  factory WebsocketManager(OnWebsocketMessage onWebsocketMessage) => getManager(onWebsocketMessage);

}