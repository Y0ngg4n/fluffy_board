import 'websocket_manager_stub.dart'
if (dart.library.io) 'websocket_manager_other.dart'
if (dart.library.html) 'websocket_manager_html.dart';

typedef OnWebsocketMessage = Function(dynamic streamData);

abstract class WebsocketManager {

  bool disconnect = false;

  initializeConnection(String whiteboard, String authToken);

  connectWs(String whiteboard, String authToken);

  onDisconnected(String whiteboard, String authToken);

  sendDataToChannel(String key, String data);

  setDisconnect(bool status);

  startListener(String whiteboard, String authToken);

  startDisconnect();

  factory WebsocketManager(OnWebsocketMessage onWebsocketMessage) => getManager(onWebsocketMessage);

}