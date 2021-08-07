
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/whiteboard/infinite_canvas.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/overlays/zoom.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../whiteboard_view.dart';
import '../../toolbar.dart' as Toolbar;

class ScribbleSettings extends StatefulWidget {
  final Scribble? selectedScribble;
  final List<Scribble> scribbles;
  final OnScribblesChange onScribblesChange;
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final WebsocketConnection? websocketConnection;
  final OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;
  final Axis axis;
  final ZoomOptions zoomOptions;
  final Offset offset;
  ScribbleSettings(
      {required this.selectedScribble,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.scribbles,
      required this.onScribblesChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard,
      required this.axis,
        required this.zoomOptions,
        required this.offset
      });

  @override
  _ScribbleSettingsState createState() => _ScribbleSettingsState();
}

class _ScribbleSettingsState extends State<ScribbleSettings> {
  double rotation = 1;

  @override
  @override
  Widget build(BuildContext context) {

    return Flex(
      mainAxisSize: MainAxisSize.min,
            direction: widget.axis,
            children: [
              Row(
                children: [
                  RotatedBox(
                    quarterTurns: widget.axis == Axis.vertical ? -1: 0,
                    child: Slider.adaptive(
                      value: widget.selectedScribble!.strokeWidth,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedScribble!.strokeWidth = value;
                        });
                      },
                      onChangeEnd: (value) {
                        widget.onSaveOfflineWhiteboard();
                        WebsocketSend.sendScribbleUpdate(
                            widget.selectedScribble!,
                            widget.websocketConnection);
                      },
                      min: 1,
                      max: 50,
                    ),
                  ),
                ],
              ),
              // SleekCircularSlider(
              //   appearance: CircularSliderAppearance(
              //       size: 50,
              //       startAngle: 270,
              //       angleRange: 360,
              //       infoProperties: InfoProperties(modifier: (double value) {
              //         final roundedValue = value.ceil().toInt().toString();
              //         return '$roundedValue °';
              //       })),
              //   initialValue: rotation,
              //   min: 0,
              //   max: 360,
              //   onChange: (value) {
              //     setState(() {
              //       rotation = value;
              //     });
              //   },
              //   onChangeEnd: (value) async {
              //     int index =
              //         widget.scribbles.indexOf(widget.selectedScribble!);
              //     widget.selectedScribble!.rotation = value;
              //     List<DrawPoint> newPoints = [];
              //     ScreenUtils.calculateScribbleBounds(widget.selectedScribble!);
              //     ScreenUtils.bakeScribble(
              //         widget.selectedScribble!, widget.zoomOptions.scale);
              //     Offset middlePoint = new Offset(
              //         (widget.selectedScribble!.rightExtremity -
              //                 widget.selectedScribble!.leftExtremity) /
              //             2,
              //         (widget.selectedScribble!.bottomExtremity -
              //                 widget.selectedScribble!.topExtremity) /
              //             2);
              //     print(middlePoint);
              //     for (DrawPoint point in widget.selectedScribble!.points) {
              //       // https://math.stackexchange.com/questions/1964905/rotation-around-non-zero-point
              //       // x′=5+(x−5)cos(φ)−(y−10)sin(φ)
              //       double newX = middlePoint.dx +
              //           (point.dx - middlePoint.dx) * cos(rotation) -
              //           (point.dy - middlePoint.dy) * sin(rotation);
              //       // y′=10+(x−5)sin(φ)+(y−10)cos(φ)
              //       double newY = middlePoint.dy +
              //           (point.dx - middlePoint.dx) * sin(rotation) +
              //           (point.dy - middlePoint.dy) * cos(rotation);
              //       newPoints.add(new DrawPoint(newX, newY));
              //     }
              //     widget.selectedScribble!.points = newPoints;
              //     widget.scribbles[index] = widget.selectedScribble!;
              //     widget.onScribblesChange(widget.scribbles);
              //     widget.onSaveOfflineWhiteboard();
              //     WebsocketSend.sendScribbleUpdate(
              //         widget.selectedScribble!, widget.websocketConnection);
              //     setState(() {
              //       rotation = 0;
              //     });
              //   },
              // ),
              OutlinedButton(
                  onPressed: () {
                    widget.toolbarOptions.colorPickerOpen =
                        !widget.toolbarOptions.colorPickerOpen;
                    widget.onChangedToolbarOptions(widget.toolbarOptions);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(OwnIcons.color_lens,
                        color: widget.selectedScribble!.color),
                  )),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.scribbles.remove(widget.selectedScribble!);
                      widget.onSaveOfflineWhiteboard();
                      WebsocketSend.sendScribbleDelete(
                          widget.selectedScribble!, widget.websocketConnection);
                      widget.onScribblesChange(widget.scribbles);
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
