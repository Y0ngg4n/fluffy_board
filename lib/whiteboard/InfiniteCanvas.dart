import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'CanvasCustomPainter.dart';

class InfiniteCanvasPage extends StatefulWidget {

  SelectedTool selectedTool;

  InfiniteCanvasPage(this.selectedTool);

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<DrawPoint> points = [];
  double scale = 0.5;
  double _initialScale = 0.5;
  Offset offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          this.setState(() {
            _initialScale = scale;
            if (widget.selectedTool == SelectedTool.pencil) {
              Offset newOffset = (details.localFocalPoint - offset) / scale;
              points.add(new DrawPoint(newOffset.dx, newOffset.dy));
            } else {
              _initialFocalPoint = details.focalPoint;
            }
          });
        },
        onScaleUpdate: (details) {
          this.setState(() {
            scale = details.scale * _initialScale;
            if (widget.selectedTool == SelectedTool.move) {
              // offset += details.localFocalPoint - offset;
              _sessionOffset = details.focalPoint - _initialFocalPoint;
              // offset = new Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            } else {
              Offset newOffset = (details.localFocalPoint - offset) / scale;
              points.add(new DrawPoint(newOffset.dx, newOffset.dy));
            }
          });
        },
        onScaleEnd: (details) {
          this.setState(() {
            offset += _sessionOffset;
            _sessionOffset = Offset.zero;
            if (widget.selectedTool == SelectedTool.pencil) {
              points.add(new DrawPoint.empty());
            }
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              painter: CanvasCustomPainter(
                  points: points,
                  offset: (offset + _sessionOffset) / scale,
                  scale: scale),
            ),
          ),
        ),
      ),
    );

  }
}
