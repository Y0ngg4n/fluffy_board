import 'dart:typed_data';

import 'WebsocketManagerStub.dart'
if (dart.library.io) 'WebsocketManagerOther.dart'
if (dart.library.html) 'WebsocketManagerHtml.dart';

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