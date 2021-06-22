import 'dart:convert';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:uuid/uuid.dart';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedUpload {
  Image,
  PDF,
}

class UploadOptions extends DrawOptions {
  SelectedUpload selectedUpload = SelectedUpload.Image;

  UploadOptions(this.selectedUpload)
      : super(List.empty(growable: false), 1, StrokeCap.round, 0, (DrawOptions)=>{});
}

class UploadToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  List<Upload> uploads;
  Offset offset;
  Offset sessionOffset;
  ZoomOptions zoomOptions;
  WebsocketConnection websocketConnection;

  UploadToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.offset,
      required this.sessionOffset,
      required this.zoomOptions,
      required this.websocketConnection});

  @override
  _UploadToolbarState createState() => _UploadToolbarState();
}

class _UploadToolbarState extends State<UploadToolbar> {
  List<bool> selectedUploadList = List.generate(3, (i) => false);
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
              ToggleButtons(
                  onPressed: (index) async {
                    widget.toolbarOptions.uploadOptions.selectedUpload =
                        SelectedUpload.values[index];
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                    FilePickerCross result =
                        await FilePickerCross.importFromStorage(
                      type: FileTypeCross.image,
                    );
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedUploadList.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          selectedUploadList[buttonIndex] = true;
                        } else {
                          selectedUploadList[buttonIndex] = false;
                        }
                      }
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
                            upload.uint8List.toList()
                        ));
                        widget.websocketConnection.channel.add("upload-add#" + data);
                      });
                    });
                  },
                  direction: Axis.vertical,
                  isSelected: selectedUploadList,
                  children: <Widget>[
                    Icon(Icons.image),
                    Icon(OwnIcons.color_lens),
                    Icon(OwnIcons.color_lens),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
