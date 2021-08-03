import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../whiteboard-data/json_encodable.dart';
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
  Axis axis;

  UploadSettings(
      {required this.selectedUpload,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.onUploadsChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard,
      required this.axis});

  @override
  _UploadSettingsState createState() => _UploadSettingsState();
}

class _UploadSettingsState extends State<UploadSettings> {
  double uploadSize = 1;
  double rotation = 0;

  @override
  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.axis,
      children: [
        RotatedBox(
          quarterTurns: widget.axis == Axis.vertical ? -1 : 0,
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
                  .instantiateImageCodec(widget.selectedUpload!.uint8List);
              final ui.FrameInfo frameInfo = await codec.getNextFrame();

              widget.selectedUpload!.image = frameInfo.image;
              widget.uploads[index] = widget.selectedUpload!;
              widget.onUploadsChange(widget.uploads);
              widget.onSaveOfflineWhiteboard();
              WebsocketSend.sendUploadImageDataUpdate(
                  widget.selectedUpload!, widget.websocketConnection);
              setState(() {
                uploadSize = 1;
              });
            },
            min: 0.1,
            max: 2,
          ),
        ),
        SleekCircularSlider(
          appearance: CircularSliderAppearance(
              size: 50,
              startAngle: 270,
              angleRange: 360,
              infoProperties: InfoProperties(modifier: (double value) {
                final roundedValue = value.ceil().toInt().toString();
                return '$roundedValue °';
              })),
          initialValue: rotation,
          min: 0,
          max: 360,
          onChange: (value) {
            setState(() {
              rotation = value;
            });
          },
          onChangeEnd: (value) async {
            int index = widget.uploads.indexOf(widget.selectedUpload!);
            widget.selectedUpload!.uint8List =
                rotateImage(widget.selectedUpload!.uint8List, value);
            final ui.Codec codec = await PaintingBinding.instance!
                .instantiateImageCodec(widget.selectedUpload!.uint8List);
            final ui.FrameInfo frameInfo = await codec.getNextFrame();

            widget.selectedUpload!.image = frameInfo.image;
            widget.uploads[index] = widget.selectedUpload!;
            widget.onUploadsChange(widget.uploads);
            widget.onSaveOfflineWhiteboard();
            WebsocketSend.sendUploadImageDataUpdate(
                widget.selectedUpload!, widget.websocketConnection);
            setState(() {
              rotation = 0;
            });
          },
        ),
        OutlinedButton(
            onPressed: () {
              setState(() {
                widget.uploads.remove(widget.selectedUpload!);
                WebsocketSend.sendUploadDelete(
                    widget.selectedUpload!, widget.websocketConnection);
                widget.onUploadsChange(widget.uploads);
                widget.onSaveOfflineWhiteboard();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(Icons.delete),
            ))
      ],
    );
  }

  Uint8List resizeImage(Uint8List data, double scaleFactor) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!,
        width: (img.width * scaleFactor).toInt(),
        height: (img.height * scaleFactor).toInt());
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }

  Uint8List rotateImage(Uint8List data, double rotateFactor) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyRotate(img!, rotateFactor);
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }
}
