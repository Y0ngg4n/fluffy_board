import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar.dart' as Toolbar;
import 'package:flutter/material.dart';
import 'dart:ui';

class ZoomOptions {
  late double scale;

  ZoomOptions(this.scale);
}

typedef OnChangedZoomOptions<T> = Function(ZoomOptions);
typedef OnChangedOffset<T> = Function(Offset);

class ZoomView extends StatefulWidget {
  final ZoomOptions zoomOptions;
  final Toolbar.ToolbarOptions toolbarOptions;
  final OnChangedZoomOptions onChangedZoomOptions;
  final OnChangedOffset onChangedOffset;
  final Offset offset;
  final String toolbarLocation;

  ZoomView(
      {required this.zoomOptions,
      required this.toolbarOptions,
      required this.onChangedZoomOptions,
      required this.onChangedOffset,
      required this.offset,
      required this.toolbarLocation});

  @override
  _ZoomViewState createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  final double zoomFactor = 0.1;

  @override
  Widget build(BuildContext context) {
    double moveFactorVertical = ScreenUtils.getScreenHeight(context);
    double moveFactorHorizontal = ScreenUtils.getScreenWidth(context);

    MainAxisAlignment mainAxisAlignmentRow;

    switch (widget.toolbarLocation) {
      case "right":
        mainAxisAlignmentRow = MainAxisAlignment.start;
        break;
      default:
        mainAxisAlignmentRow = MainAxisAlignment.end;
        break;
    }

    if (widget.toolbarOptions.colorPickerOpen) return Container();

    return Row(
      mainAxisAlignment: mainAxisAlignmentRow,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: (Column(
                  children: [
                    Row(
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                widget.onChangedOffset(widget.offset +
                                    new Offset(0, moveFactorVertical));
                              });
                            },
                            child: Icon(Icons.arrow_upward_outlined))
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                widget.onChangedOffset(widget.offset +
                                    new Offset(moveFactorHorizontal, 0));
                              });
                            },
                            child: Icon(Icons.arrow_left_outlined)),
                        OutlinedButton(
                            onPressed: () {
                              widget.onChangedOffset(Offset.zero);
                            },
                            child: Icon(Icons.reset_tv)),
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                widget.onChangedOffset(widget.offset +
                                    new Offset(-moveFactorHorizontal, 0));
                              });
                            },
                            child: Icon(Icons.arrow_right_outlined)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                widget.onChangedOffset(widget.offset +
                                    new Offset(0, -moveFactorVertical));
                              });
                            },
                            child: Icon(Icons.arrow_downward_outlined))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                      child: Row(
                        children: [
                          Text(
                            "Scale: " +
                                widget.zoomOptions.scale.toStringAsFixed(2),
                            style: TextStyle(color: Colors.black),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                if (widget.zoomOptions.scale - zoomFactor <=
                                    zoomFactor) return;
                                widget.zoomOptions.scale =
                                    widget.zoomOptions.scale - zoomFactor;
                                widget.onChangedZoomOptions(widget.zoomOptions);
                              },
                              child: Icon(Icons.remove)),
                          OutlinedButton(
                              onPressed: () {
                                if (widget.zoomOptions.scale + zoomFactor >= 5)
                                  return;
                                widget.zoomOptions.scale =
                                    widget.zoomOptions.scale + zoomFactor;
                                widget.onChangedZoomOptions(widget.zoomOptions);
                              },
                              child: Icon(Icons.add)),
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ),
          ],
        )
      ],
    );
  }
}
