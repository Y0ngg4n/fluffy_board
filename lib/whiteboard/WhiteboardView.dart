import 'dart:convert';

import 'package:fluffy_board/dashboard/Dashboard.dart';
import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:fluffy_board/whiteboard/InfiniteCanvas.dart';
import 'package:fluffy_board/whiteboard/TextsCanvas.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
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
  late WebsocketConnection websocketConnection;

  @override
  void initState() {
    super.initState();
    websocketConnection = WebsocketConnection.getInstance(
        whiteboard: widget.whiteboard.id,
        auth_token: widget.auth_token,
        onScribbleAdd: (scribble) {
          setState(() {
            scribbles.add(scribble);
          });
        },
        onScribbleUpdate: (scribble) {
          setState(() {
            // Reverse Scribble Search for better Performance
            for (int i = scribbles.length - 1; i >= 0; i--) {
              if (scribbles[i].uuid == scribble.uuid) {
                scribble.selectedFigureTypeToolbar =
                    scribbles[i].selectedFigureTypeToolbar;
                scribbles[i] = scribble;
                break;
              }
            }
          });
        },
        onScribbleDelete: (id) {
          setState(() {
            // Reverse Scribble Search for better Performance
            for (int i = scribbles.length - 1; i >= 0; i--) {
              if (scribbles[i].uuid == id) {
                scribbles.removeAt(i);
                break;
              }
            }
          });
        });
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => _createToolbars(context));
    _getToolBarOptions();
    _getWhiteboardData();
  }

  @override
  void dispose() {
    super.dispose();
    websocketConnection.dispose();
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
            auth_token: widget.auth_token,
            websocketConnection: websocketConnection,
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
    FigureOptions figureOptions = await _getFigureOptions();
    BackgroundOptions backgroundOptions = await _getBackgroundOptions();
    setState(() {
      toolbarOptions = new Toolbar.ToolbarOptions(
          Toolbar.SelectedTool.move,
          pencilOptions,
          highlighterOptions,
          straightLineOptions,
          eraserOptions,
          figureOptions,
          new UploadOptions(SelectedUpload.Image),
          new TextOptions(SelectedTextColorToolbar.ColorPreset1),
          backgroundOptions,
          false,
          Toolbar.SettingsSelected.none);
    });
  }

  Future _getWhiteboardData() async {
    await _getScribbles();
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
          decodePencilOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodePencilOptions.strokeWidth,
          StrokeCap.round,
          decodePencilOptions.selectedColor,
          (drawOptions) => _sendPencilToolbarOptions(drawOptions));
    } else {
      pencilOptions = PencilOptions(
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
          decodeHighlighterOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodeHighlighterOptions.strokeWidth,
          StrokeCap.square,
          decodeHighlighterOptions.selectedColor,
          (drawOptions) => _sendHighlighterToolbarOptions(drawOptions));
    } else {
      highlighterOptions = HighlighterOptions(
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
    http.Response straightLineResponse = await http.get(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/straight-line/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    StraightLineOptions straightLineOptions;
    if (straightLineResponse.statusCode == 200) {
      DecodeStraightLineOptions decodeStraightLineOptions =
          DecodeStraightLineOptions.fromJson(
              jsonDecode(straightLineResponse.body));
      straightLineOptions = new StraightLineOptions(
          decodeStraightLineOptions.selectedCap,
          decodeStraightLineOptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodeStraightLineOptions.strokeWidth,
          StrokeCap.square,
          decodeStraightLineOptions.selectedColor,
          (drawOptions) => _sendStraightLineToolbarOptions(drawOptions));
    } else {
      straightLineOptions = StraightLineOptions(
          0,
          List.from({Colors.black, Colors.blue, Colors.red}),
          5,
          StrokeCap.square,
          0,
          (drawOptions) => _sendStraightLineToolbarOptions(drawOptions));
    }
    return straightLineOptions;
  }

  Future<FigureOptions> _getFigureOptions() async {
    http.Response straightLineResponse = await http.get(
        Uri.parse(dotenv.env['REST_API_URL']! + "/toolbar-options/figure/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    FigureOptions figureOptions;
    if (straightLineResponse.statusCode == 200) {
      DecodeFigureptions decodeFigureptions =
          DecodeFigureptions.fromJson(jsonDecode(straightLineResponse.body));
      figureOptions = new FigureOptions(
          decodeFigureptions.selectedFigure,
          decodeFigureptions.selectedFill,
          decodeFigureptions.colorPresets
              .map((e) => HexColor.fromHex(e))
              .toList(),
          decodeFigureptions.strokeWidth,
          StrokeCap.round,
          decodeFigureptions.selectedColor,
          (drawOptions) => _sendFigureToolbarOptions(drawOptions));
    } else {
      figureOptions = FigureOptions(
          1,
          1,
          List.from({Colors.black, Colors.blue, Colors.red}),
          1,
          StrokeCap.round,
          0,
          (drawOptions) => _sendFigureToolbarOptions(drawOptions));
    }
    return figureOptions;
  }

  Future<BackgroundOptions> _getBackgroundOptions() async {
    http.Response backgroundResponse = await http.get(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/background/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        });

    BackgroundOptions backgroundOptions;
    if (backgroundResponse.statusCode == 200) {
      DecodeBackgroundOptions decodeBackgroundOptions =
          DecodeBackgroundOptions.fromJson(jsonDecode(backgroundResponse.body));
      backgroundOptions = new BackgroundOptions(
          decodeBackgroundOptions.selectedBackground,
          List.empty(),
          decodeBackgroundOptions.strokeWidth,
          StrokeCap.round,
          0,
          (drawOptions) => _sendBackgroundToolbarOptions(drawOptions));
    } else {
      backgroundOptions = BackgroundOptions(
          0,
          List.empty(),
          50,
          StrokeCap.round,
          0,
          (drawOptions) => _sendBackgroundToolbarOptions(drawOptions));
    }
    return backgroundOptions;
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
            pencilOptions.strokeWidth,
            pencilOptions.currentColor)));
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
            highlighterOptions.strokeWidth,
            highlighterOptions.currentColor)));
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
    StraightLineOptions straightLineOptions =
        drawOptions as StraightLineOptions;
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
            straightLineOptions.strokeWidth,
            straightLineOptions.currentColor,
            straightLineOptions.selectedCap)));
  }

  _sendFigureToolbarOptions(DrawOptions drawOptions) async {
    FigureOptions figureOptions = drawOptions as FigureOptions;
    await http.post(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/figure/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodeFigureOptions(
            figureOptions.colorPresets.map((e) => e.toHex()).toList(),
            figureOptions.strokeWidth,
            figureOptions.currentColor,
            figureOptions.selectedFigure,
            figureOptions.selectedFill)));
  }

  _sendBackgroundToolbarOptions(DrawOptions drawOptions) async {
    BackgroundOptions backgroundOptions = drawOptions as BackgroundOptions;
    await http.post(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/toolbar-options/background/update"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(new EncodeBackgroundOptions(
            backgroundOptions.strokeWidth,
            backgroundOptions.selectedBackground)));
  }

  Future _getScribbles() async {
    http.Response scribbleResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/whiteboard/scribble/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode({"whiteboard": widget.whiteboard.id}));

    if (scribbleResponse.statusCode == 200) {
      List<DecodeGetScribble> decodedScribbles =
          DecodeGetScribbleList.fromJsonList(jsonDecode(scribbleResponse.body));
      setState(() {
        for (DecodeGetScribble decodeGetScribble in decodedScribbles) {
          scribbles.add(new Scribble(
              decodeGetScribble.uuid,
              decodeGetScribble.strokeWidth,
              StrokeCap.values[decodeGetScribble.strokeCap],
              HexColor.fromHex(decodeGetScribble.color),
              decodeGetScribble.points,
              SelectedFigureTypeToolbar
                  .values[decodeGetScribble.selectedFigureTypeToolbar],
              PaintingStyle.values[decodeGetScribble.paintingStyle]));
        }
      });
    }
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
