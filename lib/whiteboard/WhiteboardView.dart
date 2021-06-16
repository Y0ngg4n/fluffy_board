import 'dart:convert';

import 'package:fluffy_board/dashboard/Dashboard.dart';
import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/TextsCanvas.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/BackgroundToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/DrawOptions.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/EraserToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/HighlighterToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/TextToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/UploadToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Zoom.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'DrawPoint.dart';
import 'overlays/Toolbar.dart' as Toolbar;

class WhiteboardView extends StatefulWidget {
  Whiteboard whiteboard;
  String auth_token;

  WhiteboardView(this.whiteboard, this.auth_token);

  @override
  _WhiteboardViewState createState() => _WhiteboardViewState();
}

class _WhiteboardViewState extends State<WhiteboardView> {
  Toolbar.ToolbarOptions? toolbarOptions;
  ZoomOptions zoomOptions = new ZoomOptions(1);
  List<Upload> uploads = [];
  List<TextItem> texts = [];
  List<Scribble> scribbles = [];
  Offset offset = Offset.zero;
  Offset _sessionOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => _createToolbars(context));
    _getToolBarOptions();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text(widget.whiteboard.name),
    );

    if (toolbarOptions == null) {
      return Dashboard.loading(widget.whiteboard.name);
    }

    return Scaffold(
        appBar: (appBar),
        body: Stack(children: [
          InfiniteCanvasPage(
            toolbarOptions: toolbarOptions!,
            zoomOptions: zoomOptions,
            appBarHeight: appBar.preferredSize.height,
            onScribblesChange: (scribbles) {
              setState(() {
                this.scribbles = scribbles;
              });
            },
            onChangedZoomOptions: (zoomOptions) {
              setState(() {
                this.zoomOptions = zoomOptions;
              });
            },
            offset: offset,
            texts: texts,
            sessionOffset: _sessionOffset,
            onOffsetChange: (offset, sessionOffset) => {
              setState(() {
                this.offset = offset;
                this._sessionOffset = sessionOffset;
              })
            },
            uploads: uploads,
            onChangedToolbarOptions: (toolBarOptions) {
              setState(() {
                this.toolbarOptions = toolBarOptions;
              });
            },
            scribbles: scribbles,
          ),
          TextsCanvas(
            sessionOffset: _sessionOffset,
            offset: offset,
            texts: texts,
            toolbarOptions: toolbarOptions!,
          ),
          Toolbar.Toolbar(
            scribbles: scribbles,
            toolbarOptions: toolbarOptions!,
            zoomOptions: zoomOptions,
            offset: offset,
            sessionOffset: _sessionOffset,
            uploads: uploads,
            onChangedToolbarOptions: (toolBarOptions) {
              setState(() {
                this.toolbarOptions = toolBarOptions;
              });
            },
            onScribblesChange: (scribbles) {
              setState(() {
                this.scribbles = scribbles;
              });
            },
          ),
          ZoomView(
            zoomOptions: zoomOptions,
            onChangedZoomOptions: (zoomOptions) {
              setState(() {
                this.zoomOptions = zoomOptions;
              });
            },
          )
        ]));
  }

  Future _getToolBarOptions() async {
    PencilOptions pencilOptions = await _getPencilOptions();
    HighlighterOptions highlighterOptions = await _getHighlighterOptions();
    EraserOptions eraserOptions = await _getEraserOptions();
    StraightLineOptions straightLineOptions = await _getStraightLineOptions();
    setState(() {
      toolbarOptions = new Toolbar.ToolbarOptions(
          Toolbar.SelectedTool.move,
          pencilOptions,
          highlighterOptions,
          straightLineOptions,
          eraserOptions,
          new FigureOptions(SelectedFigureColorToolbar.ColorPreset1,
              SelectedFigureTypeToolbar.rect, PaintingStyle.stroke),
          new UploadOptions(SelectedUpload.Image),
          new TextOptions(SelectedTextColorToolbar.ColorPreset1),
          new BackgroundOptions(SelectedBackgroundTypeToolbar.White),
          false,
          Toolbar.SettingsSelected.none);
    });
  }

  Future<PencilOptions> _getPencilOptions() async {
    http.Response pencilResponse = await http.get(
        Uri.parse(dotenv.env['REST_API_URL']! + "/toolbar-options/pencil/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    PencilOptions pencilOptions;
    if (pencilResponse.statusCode == 200) {
      DecodePencilOptions decodePencilOptions =
          DecodePencilOptions.fromJson(jsonDecode(pencilResponse.body));
      pencilOptions = new PencilOptions(
          SelectedPencilColorToolbar.ColorPreset1,
          decodePencilOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodePencilOptions.strokeWidth,
          StrokeCap.round,
          0,
          (drawOptions) => _sendPencilToolbarOptions(drawOptions));
    } else {
      pencilOptions = PencilOptions(
          SelectedPencilColorToolbar.ColorPreset1,
          List.from({Colors.black, Colors.blue, Colors.red}),
          1,
          StrokeCap.round,
          0,
          (drawOptions) => _sendPencilToolbarOptions(drawOptions));
    }
    return pencilOptions;
  }

  Future<HighlighterOptions> _getHighlighterOptions() async {
    http.Response highlighterResponse = await http.get(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/highlighter/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    HighlighterOptions highlighterOptions;
    if (highlighterResponse.statusCode == 200) {
      DecodeHighlighterOptions decodeHighlighterOptions =
          DecodeHighlighterOptions.fromJson(
              jsonDecode(highlighterResponse.body));
      highlighterOptions = new HighlighterOptions(
          SelectedHighlighterColorToolbar.ColorPreset1,
          decodeHighlighterOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodeHighlighterOptions.strokeWidth,
          StrokeCap.square,
          0,
          (drawOptions) => _sendHighlighterToolbarOptions(drawOptions));
    } else {
      highlighterOptions = HighlighterOptions(
          SelectedHighlighterColorToolbar.ColorPreset1,
          List.from({
            Colors.limeAccent,
            Colors.lightGreenAccent,
            Colors.lightBlueAccent
          }),
          5,
          StrokeCap.square,
          0,
          (drawOptions) => _sendHighlighterToolbarOptions(drawOptions));
    }
    return highlighterOptions;
  }

  Future<EraserOptions> _getEraserOptions() async {
    http.Response highlighterResponse = await http.get(
        Uri.parse(dotenv.env['REST_API_URL']! + "/toolbar-options/eraser/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    EraserOptions eraserOptions;
    if (highlighterResponse.statusCode == 200) {
      DecodeEraserOptions decodeEraserOptions =
          DecodeEraserOptions.fromJson(jsonDecode(highlighterResponse.body));
      eraserOptions = new EraserOptions(
          List.empty(),
          decodeEraserOptions.strokeWidth,
          StrokeCap.square,
          0,
          (drawOptions) => _sendEraserToolbarOptions(drawOptions));
    } else {
      eraserOptions = EraserOptions(List.empty(), 50, StrokeCap.square, 0,
          (drawOptions) => _sendEraserToolbarOptions(drawOptions));
    }
    return eraserOptions;
  }

  Future<StraightLineOptions> _getStraightLineOptions() async {
    http.Response highlighterResponse = await http.get(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/straight-line/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    StraightLineOptions straightLineOptions;
    if (highlighterResponse.statusCode == 200) {
      DecodeHighlighterOptions decodeHighlighterOptions =
      DecodeHighlighterOptions.fromJson(
          jsonDecode(highlighterResponse.body));
      straightLineOptions = new StraightLineOptions(
          SelectedStraightLineColorToolbar.ColorPreset1,
          SelectedStraightLineCapToolbar.Normal,
          decodeHighlighterOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodeHighlighterOptions.strokeWidth,
          StrokeCap.square,
          0,
              (drawOptions) => _sendStraightLineToolbarOptions(drawOptions));
    } else {
      straightLineOptions = StraightLineOptions(
          SelectedStraightLineColorToolbar.ColorPreset1,
          SelectedStraightLineCapToolbar.Normal,
          List.from({
            Colors.black,
            Colors.blue,
            Colors.red
          }),
          5,
          StrokeCap.square,
          0,
              (drawOptions) => _sendStraightLineToolbarOptions(drawOptions));
    }
    return straightLineOptions;
  }

  _sendPencilToolbarOptions(DrawOptions drawOptions) async {
    PencilOptions pencilOptions = drawOptions as PencilOptions;
    await http.post(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/pencil/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodePencilOptions(
            pencilOptions.colorPresets.map((e) => e.toHex()).toList(),
            pencilOptions.strokeWidth)));
  }

  _sendHighlighterToolbarOptions(DrawOptions drawOptions) async {
    HighlighterOptions highlighterOptions = drawOptions as HighlighterOptions;
    await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! +
            "/toolbar-options/highlighter/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodeHighlighterOptions(
            highlighterOptions.colorPresets.map((e) => e.toHex()).toList(),
            highlighterOptions.strokeWidth)));
  }

  _sendEraserToolbarOptions(DrawOptions drawOptions) async {
    EraserOptions eraserOptions = drawOptions as EraserOptions;
    await http.post(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/eraser/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodeEraserOptions(eraserOptions.strokeWidth)));
  }

  _sendStraightLineToolbarOptions(DrawOptions drawOptions) async {
    StraightLineOptions straightLineOptions = drawOptions as StraightLineOptions;
    await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! +
            "/toolbar-options/straight-line/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodeStraightLineOptions(
            straightLineOptions.colorPresets.map((e) => e.toHex()).toList(),
            straightLineOptions.strokeWidth)));
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
