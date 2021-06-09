import 'package:flutter/material.dart';
import 'dart:ui';

class ZoomOptions {
  late double scale;

  ZoomOptions(this.scale);
}

typedef OnChangedZoomOptions<T> = Function(ZoomOptions);

class ZoomView extends StatefulWidget {
  ZoomOptions zoomOptions;
  OnChangedZoomOptions onChangedZoomOptions;

  ZoomView({required this.zoomOptions, required this.onChangedZoomOptions});

  @override
  _ZoomViewState createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  double zoomFactor = 0.2;

  @override
  Widget build(BuildContext context) {
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
                      OutlinedButton(onPressed: () {
                        widget.zoomOptions.scale = widget.zoomOptions.scale + zoomFactor;
                        widget.onChangedZoomOptions(widget.zoomOptions);
                      }, child: Icon(Icons.add)),
                      OutlinedButton(
                          onPressed: () {
                            if(widget.zoomOptions.scale - zoomFactor <= zoomFactor) return;
                            widget.zoomOptions.scale = widget.zoomOptions.scale - zoomFactor;
                            widget.onChangedZoomOptions(widget.zoomOptions);
                          }, child: Icon(Icons.remove))
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
