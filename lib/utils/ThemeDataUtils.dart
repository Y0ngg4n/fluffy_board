import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

class ThemeDataUtils {
  static final Color veryLightBlue = HexColor.fromHex("#10b8e4");
  static final Color lightBlue = HexColor.fromHex("#04b4fc");
  static final Color blue = HexColor.fromHex("#0c3c94");
  static final Color blue2 = HexColor.fromHex("#0c3c8c");
  static final Color blue3 = HexColor.fromHex("#102084");
  static final Color darkGrey = HexColor.fromHex("#10243c");
  static final Color darkBlue = HexColor.fromHex("#1c0c3c");
  static final Color darkBlue2 = HexColor.fromHex("#200c3c");

  static getFullWidthOutlinedButtonStyle() {
    return TextButton.styleFrom(
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      backgroundColor: lightBlue,
      primary: Colors.white,
      minimumSize: const Size(double.infinity, 60),
    );
  }
}
