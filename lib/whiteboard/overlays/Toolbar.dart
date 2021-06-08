import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

enum SelectedTool {
  move,
  pencil,
  eraser,
  highlighter,
  straightLine,
}

typedef OnSelectedTool<T> = Function(SelectedTool);

class Toolbar extends StatefulWidget {
  OnSelectedTool onSelectedTool;

  Toolbar({required this.onSelectedTool});

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  List<bool> selectedToolList = List.generate(10, (i) => i == 0 ? true : false);
  SelectedTool selectedTool = SelectedTool.move;

  @override
  Widget build(BuildContext context) {
    const _borderRadius = 50.0;

    return Row(
      children: [
        Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: Column(
            children: [
              (ToggleButtons(
                direction: Axis.vertical,
                borderRadius: BorderRadius.circular(_borderRadius),
                children: <Widget>[
                  Icon(OwnIcons.move),
                  Icon(OwnIcons.pencil_alt),
                  Icon(OwnIcons.eraser),
                  Icon(OwnIcons.highlight),
                  Icon(OwnIcons.flow_line),
                  Icon(Icons.cake),
                  Icon(Icons.cake),
                  Icon(Icons.cake),
                  Icon(Icons.cake),
                  Icon(Icons.cake),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < selectedToolList.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        selectedToolList[buttonIndex] = true;
                      } else {
                        selectedToolList[buttonIndex] = false;
                      }
                    }
                    widget.onSelectedTool(SelectedTool.values[index]);
                    selectedTool = SelectedTool.values[index];
                  });
                },
                isSelected: selectedToolList,
              )),
            ],
          ),
        ),
        _openSpecialToolbar(),
      ],
    );
  }

  Widget _openSpecialToolbar() {
    switch (selectedTool) {
      case SelectedTool.move:
        return Container();
      case SelectedTool.pencil:
        return PencilToolbar();
      default:
        return Container();
    }
  }
}
