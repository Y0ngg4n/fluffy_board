import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Toolbar.dart' as Toolbar;

import 'DrawOptions.dart';

enum SelectedUpload {
  Image,
  PDF,
}

class UploadOptions extends DrawOptions {
  SelectedUpload selectedUpload =
      SelectedUpload.Image;

  UploadOptions(this.selectedUpload)
      : super(List.empty(growable: false),
      1, StrokeCap.round, 0);
}

class UploadToolbar extends StatefulWidget {
  Toolbar.ToolbarOptions toolbarOptions;
  Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;

  UploadToolbar(
      {required this.toolbarOptions, required this.onChangedToolbarOptions});

  @override
  _UploadToolbarState createState() => _UploadToolbarState();
}

class _UploadToolbarState extends State<UploadToolbar> {
  List<bool> selectedUploadList = List.generate(3, (i) => false);

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
                  onPressed: (index) {
                    setState(() async {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedUploadList.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          selectedUploadList[buttonIndex] = true;
                        } else {
                          selectedUploadList[buttonIndex] = false;
                        }
                      }

                      widget.toolbarOptions.uploadOptions.selectedUpload =
                          SelectedUpload.values[index];
                      widget.onChangedToolbarOptions(widget.toolbarOptions);
                      FilePickerResult? result = await FilePicker.platform.pickFiles();

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
