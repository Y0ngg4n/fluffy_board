import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'CanvasCustomPainter.dart';

enum CanvasState { pan, draw }

class InfiniteCanvasPage extends StatefulWidget {
  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<DrawPoint> points = [];
  CanvasState canvasState = CanvasState.draw;
  Offset offset = DrawPoint(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text(canvasState == CanvasState.draw ? "Draw" : "Pan"),
        backgroundColor:
        canvasState == CanvasState.draw ? Colors.red : Colors.blue,
        onPressed: () {
          this.setState(() {
            canvasState = canvasState == CanvasState.draw
                ? CanvasState.pan
                : CanvasState.draw;
          });
        },
      ),
      body: GestureDetector(
        onPanDown: (details) {
          this.setState(() {
            if (canvasState == CanvasState.draw) {
              Offset newOffset = details.localPosition - offset;
              points.add(new DrawPoint(newOffset.dx, newOffset.dy));
            }
          });
        },
        onPanUpdate: (details) {
          this.setState(() {
            if (canvasState == CanvasState.pan) {
              offset += details.delta;
              // offset = new Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            } else {
              Offset newOffset = details.localPosition - offset;
              points.add(new DrawPoint(newOffset.dx, newOffset.dy));
            }
          });
        },
        onPanEnd: (details) {
          this.setState(() {
            if (canvasState == CanvasState.draw) {
              points.add(new DrawPoint.empty());
            }
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              painter: CanvasCustomPainter(points: points, offset: offset),
            ),
          ),
        ),
      ),
    );
  }
}