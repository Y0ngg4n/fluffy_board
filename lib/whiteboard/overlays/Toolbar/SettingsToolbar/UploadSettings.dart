import 'dart:convert';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../DrawPoint.dart';
import '../../Toolbar.dart' as Toolbar;

class UploadSettings extends StatefulWidget {
  Upload? selectedUpload;
  List<Upload> uploads;
  OnUploadsChange onUploadsChange;
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  WebsocketConnection websocketConnection;

  UploadSettings({required this.selectedUpload,
  required this.toolbarOptions,
  required this.onChangedToolbarOptions,
  required this.uploads,
  required this.onUploadsChange,
  required this.websocketConnection});

  @override
  _UploadSettingsState createState() => _UploadSettingsState();
}

class _UploadSettingsState extends State<UploadSettings> {
  @override
  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              OutlinedButton(onPressed: () {
                setState(() {
                  widget.uploads.remove(widget.selectedUpload!);
                  widget.onUploadsChange(widget.uploads);
                  sendUploadDelete(widget.selectedUpload!);
                });
              }, child: Icon(Icons.delete))
            ],
          ),
        ),
      ),
    );
  }

  sendUploadDelete(Upload newUpload){
    String data = jsonEncode(WSUploadDelete(
      newUpload.uuid,
    ));
    widget.websocketConnection.channel
        .add("upload-delete#" + data);
  }
}
