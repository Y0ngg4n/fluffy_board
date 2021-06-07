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
  List<Scribble> scribbles = [];
  double scale = 0.5;
  double _initialScale = 0.5;
  Offset offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  Scribble scribble = new Scribble([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          this.setState(() {
            _initialScale = scale;
            if (widget.selectedTool == SelectedTool.pencil) {
              Offset newOffset = (details.localFocalPoint - offset) / scale;
              scribbles.add(new Scribble(new List.filled(
                  1, new DrawPoint(newOffset.dx, newOffset.dy),
                  growable: true)));
            } else {
              _initialFocalPoint = details.focalPoint;
            }
          });
        },
        onScaleUpdate: (details) {
          Offset newOffset = (details.localFocalPoint - offset) / scale;
          this.setState(() {
            scale = details.scale * _initialScale;
            if (widget.selectedTool == SelectedTool.move) {
              // offset += details.localFocalPoint - offset;
              _sessionOffset = details.focalPoint - _initialFocalPoint;
              // offset = new Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            } else if (widget.selectedTool == SelectedTool.eraser) {
              double minDxOffset = newOffset.dx - 10;
              double maxDxOffset = newOffset.dx + 10;
              double minDyOffset = newOffset.dy - 10;
              double maxDyOffset = newOffset.dy + 10;
              for (Scribble scribble in scribbles) {
                for (DrawPoint point in scribble.points) {
                  if (newOffset.dx <= minDxOffset - point.dx  && newOffset.dx <= maxDxOffset - point.dx
                    && newOffset.dy <= minDyOffset - point.dy  && newOffset.dy <= maxDyOffset - point.dy) {
                    print("IFFFF");
                    scribbles.remove(scribble);
                  }
                }
              }
            } else {
              scribbles[scribbles.length - 1]
                  .points
                  .add(new DrawPoint(newOffset.dx, newOffset.dy));
            }
          });
        },
        onScaleEnd: (details) {
          this.setState(() {
            offset += _sessionOffset;
            _sessionOffset = Offset.zero;
            // if (widget.selectedTool == SelectedTool.pencil) {
            //   setState(() {
            //     // scribbles.remove(scribble);
            //     // scribbles.add(scribble);
            //   });
            // }
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              painter: CanvasCustomPainter(
                  scribbles: scribbles,
                  offset: (offset + _sessionOffset) / scale,
                  scale: scale),
            ),
          ),
        ),
      ),
    );
  }
}
