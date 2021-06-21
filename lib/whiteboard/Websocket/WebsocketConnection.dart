import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebsocketConnection {
  static WebsocketConnection? _singleton = null;

  StreamController<String> streamController =
      new StreamController.broadcast(sync: true);

  late WebSocket channel;
  String whiteboard;
  String auth_token;

  WebsocketConnection(this.whiteboard, this.auth_token);

  static WebsocketConnection getInstance(String whiteboard, String auth_token) {
    if(_singleton == null) {
      _singleton = new WebsocketConnection(whiteboard, auth_token);
      _singleton!.initWebSocketConnection(whiteboard, auth_token);
    };
    return _singleton!;
  }

  initWebSocketConnection(String whiteboard, String auth_token) async {
    print("conecting...");
    this.channel = await connectWs(whiteboard, auth_token);
    // this.channel.pingInterval = Duration(seconds: 5);
    print("socket connection initialized");
    this.channel.done.then((dynamic _) => _onDisconnected(whiteboard, auth_token));
    broadcastNotifications(whiteboard, auth_token);
  }

  broadcastNotifications(String whiteboard, String auth_token) {
    this.channel.listen((streamData) {
      streamController.add(streamData);
    }, onDone: () {
      print("connecting aborted");
      initWebSocketConnection(whiteboard, auth_token);
    }, onError: (e) {
      print('Server error: $e');
      initWebSocketConnection(whiteboard, auth_token);
    });
  }

  connectWs(String whiteboard, String auth_token) async {
    try {
      return await WebSocket.connect(dotenv.env['WS_API_URL']! + "/$whiteboard/$auth_token");
    } catch (e) {
      print("Error! can not connect WS connectWs " + e.toString());
      await Future.delayed(Duration(milliseconds: 10000));
      return await connectWs(whiteboard, auth_token);
    }
  }

  void _onDisconnected(String whiteboard, String auth_token) {
    initWebSocketConnection(whiteboard, auth_token);
  }
}
