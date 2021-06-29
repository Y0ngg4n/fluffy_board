import 'dart:convert';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PDFImport.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:uuid/uuid.dart';

import '../../WhiteboardView.dart';
import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

class UploadToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  List<Upload> uploads;
  Offset offset;
  Offset sessionOffset;
  ZoomOptions zoomOptions;
  WebsocketConnection? websocketConnection;
  OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;


  UploadToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.zoomOptions,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard});

  @override
  _UploadToolbarState createState() => _UploadToolbarState();
}

class _UploadToolbarState extends State<UploadToolbar> {
  List<bool> selectedUploadList = List.generate(1, (i) => false);
  var uuid = Uuid();

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
              OutlinedButton(
                onPressed: () async {
                  FilePickerCross result =
                      await FilePickerCross.importFromStorage(
                    type: FileTypeCross.image,
                  );
                  setState(() {
                    ui.decodeImageFromList(result.toUint8List(), (image) {
                      Upload upload = new Upload(
                          uuid.v4(),
                          UploadType.Image,
                          result.toUint8List(),
                          widget.offset +
                              new Offset(
                                  (ScreenUtils.getScreenWidth(context) / 2) -
                                      (image.width / 2),
                                  (ScreenUtils.getScreenHeight(context) / 2) -
                                      (image.height / 2)),
                          image);
                      widget.uploads.add(upload);
                      String data = jsonEncode(WSUploadAdd(
                          upload.uuid,
                          upload.uploadType.index,
                          upload.offset.dx,
                          upload.offset.dy,
                          // List.generate(10, (index) => 0)
                          upload.uint8List.toList()));
                      if (widget.websocketConnection != null)
                        widget.websocketConnection!.channel
                            .add("upload-add#" + data);
                      widget.onSaveOfflineWhiteboard();
                    });
                  });
                },
                child: Icon(Icons.image),
              ),
              OutlinedButton(
                onPressed: () async {
                  final ImportedPDF result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PDFImport()),
                  ) as ImportedPDF;

                  for (int i = 0; i < result.images.length; i++) {
                    Offset offset = widget.offset +
                        new Offset(
                            (ScreenUtils.getScreenWidth(context) / 2) -
                                (result.images[i].width / 2),
                            (result.images[i].height + result.spacing) * i);
                    Upload upload = new Upload(uuid.v4(), UploadType.PDF,
                        result.imageData[i], offset, result.images[i]);
                    widget.uploads.add(upload);
                    String data = jsonEncode(WSUploadAdd(
                        upload.uuid,
                        upload.uploadType.index,
                        upload.offset.dx,
                        upload.offset.dy,
                        // List.generate(10, (index) => 0)
                        upload.uint8List.toList()));
                    if (widget.websocketConnection != null)
                      widget.websocketConnection!.channel
                          .add("upload-add#" + data);
                    widget.onSaveOfflineWhiteboard();
                  }
                },
                child: Icon(Icons.picture_as_pdf),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
