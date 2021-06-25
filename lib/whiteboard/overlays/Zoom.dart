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

  ZoomView(
      {required this.zoomOptions,
      required this.onChangedZoomOptions,
      required this.onChangedOffset,
      required this.offset});

  @override
  _ZoomViewState createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  double zoomFactor = 0.2;

  @override
  Widget build(BuildContext context) {
    double moveFactorVertical = ScreenUtils.getScreenHeight(context);
    double moveFactorHorizontal = ScreenUtils.getScreenWidth(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Card(
              child: (Column(
                children: [
                  Row(
                    children: [
                      OutlinedButton(onPressed: (){setState(() {
                        widget.offset += new Offset(0, moveFactorVertical);
                        widget.onChangedOffset(widget.offset);
                      });}, child: Icon(Icons.arrow_upward_outlined))
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(onPressed: (){setState(() {
                        widget.offset += new Offset(moveFactorHorizontal, 0);
                        widget.onChangedOffset(widget.offset);
                      });}, child: Icon(Icons.arrow_left_outlined)),
                      OutlinedButton(onPressed: (){
                        widget.onChangedOffset(Offset.zero);
                      }, child: Icon(Icons.reset_tv)),
                      OutlinedButton(onPressed: (){setState(() {
                        widget.offset += new Offset(-moveFactorHorizontal, 0);
                        widget.onChangedOffset(widget.offset);
                      });}, child: Icon(Icons.arrow_right_outlined)),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(onPressed: (){setState(() {
                        widget.offset += new Offset(0, -moveFactorVertical);
                        widget.onChangedOffset(widget.offset);
                      });}, child: Icon(Icons.arrow_downward_outlined))
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            widget.zoomOptions.scale =
                                widget.zoomOptions.scale + zoomFactor;
                            widget.onChangedZoomOptions(widget.zoomOptions);
                          },
                          child: Icon(Icons.add)),
                      OutlinedButton(
                          onPressed: () {
                            if (widget.zoomOptions.scale - zoomFactor <=
                                zoomFactor) return;
                            widget.zoomOptions.scale =
                                widget.zoomOptions.scale - zoomFactor;
                            widget.onChangedZoomOptions(widget.zoomOptions);
                          },
                          child: Icon(Icons.remove))
                    ],
                  )
                ],
              )),
            )
          ],
        )
      ],
    );
  }
}
