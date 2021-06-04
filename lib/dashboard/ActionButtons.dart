import 'package:flutter/material.dart';
import 'dart:ui';

class ActionButtons extends StatefulWidget {
  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Create Whiteboard")),
            ElevatedButton(onPressed: () {}, child: Text("Create Folder")),
          ],
        ));
  }
}
