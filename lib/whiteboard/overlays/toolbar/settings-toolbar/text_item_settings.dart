
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/infinite_canvas.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:flutter/material.dart';

import '../../../whiteboard_view.dart';
import '../../toolbar.dart' as Toolbar;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class TextItemSettings extends StatefulWidget {
  final TextItem? selectedTextItem;
  final List<TextItem> texts;
  final OnTextItemsChange onTextItemsChange;
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final WebsocketConnection? websocketConnection;
  final OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;
  final Axis axis;
  TextItemSettings(
      {required this.selectedTextItem,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.texts,
      required this.onTextItemsChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard,
      required this.axis});

  @override
  _TextItemSettingsState createState() => _TextItemSettingsState();
}

class _TextItemSettingsState extends State<TextItemSettings> {
  double rotation = 0;
  @override
  Widget build(BuildContext context) {

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              RotatedBox(
                quarterTurns: widget.axis == Axis.vertical ? -1: 0,
                child: Slider.adaptive(
                  value: widget.selectedTextItem!.strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      widget.selectedTextItem!.strokeWidth = value;
                      widget.onTextItemsChange(widget.texts);
                    });
                  },
                  onChangeEnd: (value) {
                    widget.onSaveOfflineWhiteboard();
                      WebsocketSend.sendUpdateTextItem(widget.selectedTextItem!, widget.websocketConnection);
                  },
                  min: 10,
                  max: 250,
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
                initialValue: widget.selectedTextItem == null ? rotation : widget.selectedTextItem!.rotation,
                min: 0,
                max: 360,
                onChange: (value) {
                  setState(() {
                    widget.selectedTextItem!.rotation = value;
                    int index = widget.texts.indexOf(widget.selectedTextItem!);
                    widget.selectedTextItem!.rotation = value;
                    widget.texts[index] = widget.selectedTextItem!;
                    widget.onTextItemsChange(widget.texts);
                  });
                },
                onChangeEnd: (value) async {
                  int index = widget.texts.indexOf(widget.selectedTextItem!);
                  widget.selectedTextItem!.rotation = value;
                  widget.texts[index] = widget.selectedTextItem!;
                  widget.onTextItemsChange(widget.texts);
                  widget.onSaveOfflineWhiteboard();
                  WebsocketSend.sendUpdateTextItem(widget.selectedTextItem!, widget.websocketConnection);
                },
              ),
              OutlinedButton(
                  onPressed: () {
                    widget.toolbarOptions.colorPickerOpen =
                        !widget.toolbarOptions.colorPickerOpen;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(OwnIcons.color_lens,
                        color: widget.selectedTextItem!.color),
                  )),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.texts.remove(widget.selectedTextItem!);
                      widget.onTextItemsChange(widget.texts);
                      widget.onSaveOfflineWhiteboard();
                      WebsocketSend.sendTextItemDelete(widget.selectedTextItem!, widget.websocketConnection);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(Icons.delete),
                  ))
            ],
    );
  }
}
