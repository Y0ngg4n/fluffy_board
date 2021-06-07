import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class PencilToolbar extends StatefulWidget {
  @override
  _PencilToolbarState createState() => _PencilToolbarState();
}

class _PencilToolbarState extends State<PencilToolbar> {
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
        child: Column(
          children: [ElevatedButton(onPressed: () {}, child: Text("Test"))],
        ),
      ),
    );
  }
}
