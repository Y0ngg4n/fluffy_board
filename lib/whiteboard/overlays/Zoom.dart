import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ZoomOptions {
  late double scale;

  ZoomOptions(this.scale);
}

typedef OnChangedZoomOptions<T> = Function(ZoomOptions);
typedef OnChangedOffset<T> = Function(Offset);

class ZoomView extends StatefulWidget {
  ZoomOptions zoomOptions;
  OnChangedZoomOptions onChangedZoomOptions;
  OnChangedOffset onChangedOffset;
  Offset offset;
  String toolbarLocation;

  ZoomView(
      {required this.zoomOptions,
      required this.onChangedZoomOptions,
      required this.onChangedOffset,
      required this.offset,
      required this.toolbarLocation});

  @override
  _ZoomViewState createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  double zoomFactor = 0.1;

  @override
  Widget build(BuildContext context) {
    double moveFactorVertical = ScreenUtils.getScreenHeight(context);
    double moveFactorHorizontal = ScreenUtils.getScreenWidth(context);

    final buttonStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.resolveWith((states) => Colors.white70),
    );

    MainAxisAlignment mainAxisAlignmentRow;

    switch (widget.toolbarLocation) {
      case "right":
        mainAxisAlignmentRow = MainAxisAlignment.start;
        break;
      default:
        mainAxisAlignmentRow = MainAxisAlignment.end;
        break;
    }

    return Row(
      mainAxisAlignment: mainAxisAlignmentRow,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,4,0),
                child: (Column(
                  children: [
                    Row(
                      children: [
                        OutlinedButton(
                            style: buttonStyle,
                            onPressed: () {
                              setState(() {
                                widget.offset +=
                                    new Offset(0, moveFactorVertical);
                                widget.onChangedOffset(widget.offset);
                              });
                            },
                            child: Icon(Icons.arrow_upward_outlined))
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                            style: buttonStyle,
                            onPressed: () {
                              setState(() {
                                widget.offset +=
                                    new Offset(moveFactorHorizontal, 0);
                                widget.onChangedOffset(widget.offset);
                              });
                            },
                            child: Icon(Icons.arrow_left_outlined)),
                        OutlinedButton(
                            style: buttonStyle,
                            onPressed: () {
                              widget.onChangedOffset(Offset.zero);
                            },
                            child: Icon(Icons.reset_tv)),
                        OutlinedButton(
                            style: buttonStyle,
                            onPressed: () {
                              setState(() {
                                widget.offset +=
                                    new Offset(-moveFactorHorizontal, 0);
                                widget.onChangedOffset(widget.offset);
                              });
                            },
                            child: Icon(Icons.arrow_right_outlined)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                            style: buttonStyle,
                            onPressed: () {
                              setState(() {
                                widget.offset +=
                                    new Offset(0, -moveFactorVertical);
                                widget.onChangedOffset(widget.offset);
                              });
                            },
                            child: Icon(Icons.arrow_downward_outlined))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                      child: Row(
                        children: [
                          OutlinedButton(
                              style: buttonStyle,
                              onPressed: () {
                                if (widget.zoomOptions.scale - zoomFactor <=
                                    zoomFactor) return;
                                widget.zoomOptions.scale =
                                    widget.zoomOptions.scale - zoomFactor;
                                widget.onChangedZoomOptions(widget.zoomOptions);
                              },
                              child: Icon(Icons.remove)),
                          OutlinedButton(
                              style: buttonStyle,
                              onPressed: () {
                                if(widget.zoomOptions.scale + zoomFactor >= 5) return;
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
