import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/Websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/upload-toolbar/pdf_import.dart';
import 'package:fluffy_board/whiteboard/overlays/zoom.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:uuid/uuid.dart';

import '../../whiteboard_view.dart';
import '../toolbar.dart' as Toolbar;

class UploadToolbar extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final  List<Upload> uploads;
  final Offset offset;
  final Offset sessionOffset;
  final ZoomOptions zoomOptions;
  final WebsocketConnection? websocketConnection;
  final OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;
  final Axis axis;

  UploadToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.zoomOptions,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard,
      required this.axis});

  @override
  _UploadToolbarState createState() => _UploadToolbarState();
}

class _UploadToolbarState extends State<UploadToolbar> {
  List<bool> selectedUploadList = List.generate(1, (i) => false);
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              OutlinedButton(
                onPressed: () async {
                  FilePickerCross result =
                      await FilePickerCross.importFromStorage(
                    type: FileTypeCross.image,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to import your Image ...")));
                  setState(() {
                    ui.decodeImageFromList(result.toUint8List(), (image) {
                      Upload upload = new Upload(
                          uuid.v4(),
                          UploadType.Image,
                          result.toUint8List(),
                              new Offset(
                                  (ScreenUtils.getScreenWidth(context) / 2) -
                                      (image.width / 2),
                                  (ScreenUtils.getScreenHeight(context) / 2) -
                                      (image.height / 2) ) - widget.offset,
                          image);
                      widget.uploads.add(upload);
                      WebsocketSend.sendUploadCreate(upload, widget.websocketConnection);
                      widget.onSaveOfflineWhiteboard();
                    });
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(Icons.image),
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  final ImportedPDF result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PDFImport()),
                  ) as ImportedPDF;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Trying to import your PDF ...")));
                  for (int i = 0; i < result.images.length; i++) {
                    Offset offset =
                        new Offset(
                            (ScreenUtils.getScreenWidth(context) / 2) -
                                (result.images[i].width / 2),
                            (result.images[i].height + result.spacing) * i) - widget.offset;
                    Upload upload = new Upload(uuid.v4(), UploadType.PDF,
                        result.imageData[i], offset, result.images[i]);
                    widget.uploads.add(upload);
                    WebsocketSend.sendUploadCreate(upload, widget.websocketConnection);
                    widget.onSaveOfflineWhiteboard();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(Icons.picture_as_pdf),
                ),
              ),
            ],
    );
  }
}
