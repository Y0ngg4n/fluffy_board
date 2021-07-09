import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;

import '../../../DrawPoint.dart';
import '../../../WhiteboardView.dart';
import '../../Toolbar.dart' as Toolbar;

class UploadSettings extends StatefulWidget {
  Upload? selectedUpload;
  List<Upload> uploads;
  OnUploadsChange onUploadsChange;
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  WebsocketConnection? websocketConnection;
  OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;

  UploadSettings(
      {required this.selectedUpload,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.onUploadsChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard});

  @override
  _UploadSettingsState createState() => _UploadSettingsState();
}

class _UploadSettingsState extends State<UploadSettings> {
  double uploadSize = 1;

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
              RotatedBox(
                quarterTurns: -1,
                child: Slider.adaptive(
                  value: uploadSize,
                  onChanged: (value) async {
                    setState(() {
                      uploadSize = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    int index = widget.uploads.indexOf(widget.selectedUpload!);
                    widget.selectedUpload!.uint8List =
                        resizeImage(widget.selectedUpload!.uint8List, value);
                    final ui.Codec codec = await PaintingBinding.instance!
                        .instantiateImageCodec(
                            widget.selectedUpload!.uint8List);
                    final ui.FrameInfo frameInfo = await codec.getNextFrame();

                    widget.selectedUpload!.image = frameInfo.image;
                    widget.uploads[index] = widget.selectedUpload!;
                    widget.onUploadsChange(widget.uploads);
                    widget.onSaveOfflineWhiteboard();
                    setState(() {
                      uploadSize = 1;
                    });
                  },
                  min: 0.01,
                  max: 2,
                ),
              ),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.uploads.remove(widget.selectedUpload!);
                      sendUploadDelete(widget.selectedUpload!);
                      widget.onUploadsChange(widget.uploads);
                      widget.onSaveOfflineWhiteboard();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(Icons.delete),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  sendUploadDelete(Upload newUpload) {
    String data = jsonEncode(WSUploadDelete(
      newUpload.uuid,
    ));
    if (widget.websocketConnection != null)
      widget.websocketConnection!.sendDataToChannel("upload-delete#", data);
  }

  Uint8List resizeImage(Uint8List data, double scaleFactor) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    print(scaleFactor);
    print(img!.width.toString());
    print(img.height.toString());
    print(img.height.toString() * scaleFactor.toInt());
    IMG.Image resized = IMG.copyResize(img,
        width: (img.width * scaleFactor).toInt(),
        height: (img.height * scaleFactor).toInt());
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }
}
