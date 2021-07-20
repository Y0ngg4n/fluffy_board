import 'dart:convert';

import 'package:fluffy_board/whiteboard/overlays/Toolbar/BackgroundToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/DrawOptions.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/EraserToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/HighlighterToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/PencilToolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/StraightLineToolbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';

import '../WhiteboardView.dart';

class GetToolbarOptions {
  static final LocalStorage settingsStorage = new LocalStorage('settings');

  static Future<PencilOptions> getPencilOptions(String auth_token,
      bool online) async {
    PencilOptions pencilOptions = PencilOptions(
        List.from({Colors.black, Colors.blue, Colors.red}),
        1,
        StrokeCap.round,
        0,
            (drawOptions) =>
            _sendPencilToolbarOptions(drawOptions, auth_token, online));
    if (online) {
      http.Response pencilResponse = await http.get(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/pencil/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

      if (pencilResponse.statusCode == 200) {
        DecodePencilOptions decodePencilOptions =
        DecodePencilOptions.fromJson(jsonDecode(pencilResponse.body));
        pencilOptions = new PencilOptions(
            decodePencilOptions.colorPresets
                .map((e) => HexColor.fromHex(e))
                .cast<Color>()
                .toList(),
            decodePencilOptions.strokeWidth,
            StrokeCap.round,
            decodePencilOptions.selectedColor,
                (drawOptions) =>
                _sendPencilToolbarOptions(drawOptions, auth_token, online));
        return pencilOptions;
      }
    } else {
      String? decodablePencilOptions = settingsStorage.getItem(
          "pencil-options");
      if (decodablePencilOptions != null) {
        DecodePencilOptions decodePencilOptions =
        DecodePencilOptions.fromJson(jsonDecode(decodablePencilOptions));
        pencilOptions = new PencilOptions(
            decodePencilOptions.colorPresets
                .map((e) => HexColor.fromHex(e))
                .cast<Color>()
                .toList(),
            decodePencilOptions.strokeWidth,
            StrokeCap.round,
            decodePencilOptions.selectedColor,
                (drawOptions) =>
                _sendPencilToolbarOptions(drawOptions, auth_token, online));
        return pencilOptions;
      }
    }
    return pencilOptions;
  }

  static Future<HighlighterOptions> getHighlighterOptions(String auth_token,
      bool online) async {
    HighlighterOptions highlighterOptions = HighlighterOptions(
        List.from({
          Colors.limeAccent,
          Colors.lightGreenAccent,
          Colors.lightBlueAccent
        }),
        5,
        StrokeCap.square,
        0,
            (drawOptions) =>
            _sendHighlighterToolbarOptions(drawOptions, auth_token, online));
    if (online) {
      http.Response highlighterResponse = await http.get(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/highlighter/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

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
                (drawOptions) =>
                _sendHighlighterToolbarOptions(
                    drawOptions, auth_token, online));
      }
    } else {
      String? decodableHighlighterOptions =
      settingsStorage.getItem("highlighter-options");
      if (decodableHighlighterOptions != null) {
        DecodeHighlighterOptions decodeHighlighterOptions =
        DecodeHighlighterOptions.fromJson(
            jsonDecode(decodableHighlighterOptions));
        highlighterOptions = new HighlighterOptions(
            decodeHighlighterOptions.colorPresets
                .map((e) => HexColor.fromHex(e))
                .toList(),
            decodeHighlighterOptions.strokeWidth,
            StrokeCap.square,
            decodeHighlighterOptions.selectedColor,
                (drawOptions) =>
                _sendHighlighterToolbarOptions(
                    drawOptions, auth_token, online));
        return highlighterOptions;
      }
    }
    return highlighterOptions;
  }

  static Future<EraserOptions> getEraserOptions(String auth_token,
      bool online) async {
    EraserOptions eraserOptions = EraserOptions(
        List.empty(),
        50,
        StrokeCap.square,
        0,
            (drawOptions) =>
            _sendEraserToolbarOptions(drawOptions, auth_token, online));
    if (online) {
      http.Response highlighterResponse = await http.get(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/eraser/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

      if (highlighterResponse.statusCode == 200) {
        DecodeEraserOptions decodeEraserOptions =
        DecodeEraserOptions.fromJson(jsonDecode(highlighterResponse.body));
        eraserOptions = new EraserOptions(
            List.empty(),
            decodeEraserOptions.strokeWidth,
            StrokeCap.square,
            0,
                (drawOptions) =>
                _sendEraserToolbarOptions(drawOptions, auth_token, online));
      }
    } else {
      String? decodableEraserOptions = settingsStorage.getItem(
          "eraser-options");
      if (decodableEraserOptions != null) {
        DecodeEraserOptions decodeEraserOptions =
        DecodeEraserOptions.fromJson(
            jsonDecode(decodableEraserOptions));
        eraserOptions = new EraserOptions(
            List.empty(),
            decodeEraserOptions.strokeWidth,
            StrokeCap.square,
            0,
                (drawOptions) =>
                _sendEraserToolbarOptions(drawOptions, auth_token, online));
        return eraserOptions;
      }
    }
    return eraserOptions;
  }

  static Future<StraightLineOptions> getStraightLineOptions(String auth_token,
      bool online) async {
    StraightLineOptions straightLineOptions = StraightLineOptions(
        0,
        List.from({Colors.black, Colors.blue, Colors.red}),
        5,
        StrokeCap.round,
        0,
            (drawOptions) =>
            _sendStraightLineToolbarOptions(drawOptions, auth_token, online));

    if (online) {
      http.Response straightLineResponse = await http.get(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
              "/toolbar-options/straight-line/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

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
                (drawOptions) =>
                _sendStraightLineToolbarOptions(
                    drawOptions, auth_token, online));
      }
    } else {
      String? decodableStraightLineOptions =
      settingsStorage.getItem("straight-line-options");
      if (decodableStraightLineOptions != null) {
        DecodeStraightLineOptions decodeStraightLineOptions =
        DecodeStraightLineOptions.fromJson(
            jsonDecode(decodableStraightLineOptions));
        straightLineOptions = new StraightLineOptions(
            decodeStraightLineOptions.selectedCap,
            decodeStraightLineOptions.colorPresets
                .map((e) => HexColor.fromHex(e))
                .toList(),
            decodeStraightLineOptions.strokeWidth,
            StrokeCap.square,
            decodeStraightLineOptions.selectedColor,
                (drawOptions) =>
                _sendStraightLineToolbarOptions(
                    drawOptions, auth_token, online));
      }
    }
    return straightLineOptions;
  }

  static Future<FigureOptions> getFigureOptions(String auth_token,
      bool online) async {
    FigureOptions figureOptions = FigureOptions(
        1,
        1,
        List.from({Colors.black, Colors.blue, Colors.red}),
        1,
        StrokeCap.round,
        0,
            (drawOptions) =>
            _sendFigureToolbarOptions(drawOptions, auth_token, online));
    if (online) {
      http.Response straightLineResponse = await http.get(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/figure/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

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
                (drawOptions) =>
                _sendFigureToolbarOptions(drawOptions, auth_token, online));
      }
    } else {
      String? decodableFigureOptions =
      settingsStorage.getItem("figure-options");
      if (decodableFigureOptions != null) {
        DecodeFigureptions decodeFigureOptions =
        DecodeFigureptions.fromJson(jsonDecode(decodableFigureOptions));
        figureOptions = new FigureOptions(
            decodeFigureOptions.selectedFigure,
            decodeFigureOptions.selectedFill,
            decodeFigureOptions.colorPresets
                .map((e) => HexColor.fromHex(e))
                .toList(),
            decodeFigureOptions.strokeWidth,
            StrokeCap.round,
            decodeFigureOptions.selectedColor,
                (drawOptions) =>
                _sendFigureToolbarOptions(drawOptions, auth_token, online));
      }
    }
    return figureOptions;
  }

  static Future<BackgroundOptions> getBackgroundOptions(String auth_token,
      bool online) async {
    BackgroundOptions backgroundOptions = BackgroundOptions(
        0,
        List.empty(),
        50,
        StrokeCap.round,
        0,
            (drawOptions) =>
            _sendBackgroundToolbarOptions(drawOptions, auth_token, online));
    if (online) {
      http.Response backgroundResponse = await http.get(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/background/get"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          });

      if (backgroundResponse.statusCode == 200) {
        DecodeBackgroundOptions decodeBackgroundOptions =
        DecodeBackgroundOptions.fromJson(jsonDecode(backgroundResponse.body));
        backgroundOptions = new BackgroundOptions(
            decodeBackgroundOptions.selectedBackground,
            List.empty(),
            decodeBackgroundOptions.strokeWidth,
            StrokeCap.round,
            0,
                (drawOptions) =>
                _sendBackgroundToolbarOptions(drawOptions, auth_token, online));
      }
    } else {
      String? decodableBackgroundOptions =
      settingsStorage.getItem("background-options");
      if (decodableBackgroundOptions != null) {
        DecodeBackgroundOptions decodeBackgroundOptions =
        DecodeBackgroundOptions.fromJson(
            jsonDecode(decodableBackgroundOptions));
        backgroundOptions = new BackgroundOptions(
            decodeBackgroundOptions.selectedBackground,
            List.empty(),
            decodeBackgroundOptions.strokeWidth,
            StrokeCap.round,
            0,
                (drawOptions) =>
                _sendBackgroundToolbarOptions(drawOptions, auth_token, online));
      }
    }
    return backgroundOptions;
  }

  static _sendPencilToolbarOptions(DrawOptions drawOptions, String auth_token,
      bool online) async {
    PencilOptions pencilOptions = drawOptions as PencilOptions;
    if (online) {
      await http.post(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/pencil/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodePencilOptions(
              pencilOptions.colorPresets.map((e) => e.toHex()).toList(),
              pencilOptions.strokeWidth,
              pencilOptions.currentColor)));
    } else {
      settingsStorage.setItem(
          "pencil-options",
          jsonEncode(new EncodePencilOptions(
              pencilOptions.colorPresets.map((e) => e.toHex()).toList(),
              pencilOptions.strokeWidth,
              pencilOptions.currentColor)));
    }
  }

  static _sendHighlighterToolbarOptions(DrawOptions drawOptions,
      String auth_token, bool online) async {
    HighlighterOptions highlighterOptions = drawOptions as HighlighterOptions;
    if (online) {
      await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
              "/toolbar-options/highlighter/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodeHighlighterOptions(
              highlighterOptions.colorPresets.map((e) => e.toHex()).toList(),
              highlighterOptions.strokeWidth,
              highlighterOptions.currentColor)));
    } else {
      settingsStorage.setItem(
          "highlighter-options",
          jsonEncode(new EncodeHighlighterOptions(
              highlighterOptions.colorPresets.map((e) => e.toHex()).toList(),
              highlighterOptions.strokeWidth,
              highlighterOptions.currentColor)));
    }
  }

  static _sendEraserToolbarOptions(DrawOptions drawOptions, String auth_token,
      bool online) async {
    EraserOptions eraserOptions = drawOptions as EraserOptions;
    if (online) {
      await http.post(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/eraser/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodeEraserOptions(eraserOptions.strokeWidth)));
    } else {
      settingsStorage.setItem("eraser-options",
          jsonEncode(new EncodeEraserOptions(eraserOptions.strokeWidth)));
    }
  }

  static _sendStraightLineToolbarOptions(DrawOptions drawOptions,
      String auth_token, bool online) async {
    StraightLineOptions straightLineOptions =
    drawOptions as StraightLineOptions;
    if (online) {
      await http.post(
          Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
              "/toolbar-options/straight-line/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodeStraightLineOptions(
              straightLineOptions.colorPresets.map((e) => e.toHex()).toList(),
              straightLineOptions.strokeWidth,
              straightLineOptions.currentColor,
              straightLineOptions.selectedCap)));
    } else {
      settingsStorage.setItem(
          "straight-line-options",
          jsonEncode(new EncodeStraightLineOptions(
              straightLineOptions.colorPresets.map((e) => e.toHex()).toList(),
              straightLineOptions.strokeWidth,
              straightLineOptions.currentColor,
              straightLineOptions.selectedCap)));
    }
  }

  static _sendFigureToolbarOptions(DrawOptions drawOptions, String auth_token,
      bool online) async {
    FigureOptions figureOptions = drawOptions as FigureOptions;
    if (online) {
      await http.post(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/toolbar-options/figure/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodeFigureOptions(
              figureOptions.colorPresets.map((e) => e.toHex()).toList(),
              figureOptions.strokeWidth,
              figureOptions.currentColor,
              figureOptions.selectedFigure,
              figureOptions.selectedFill)));
    } else {
      settingsStorage.setItem(
          "figure-options",
          jsonEncode(new EncodeFigureOptions(
              figureOptions.colorPresets.map((e) => e.toHex()).toList(),
              figureOptions.strokeWidth,
              figureOptions.currentColor,
              figureOptions.selectedFigure,
              figureOptions.selectedFill)));
    }
  }

  static _sendBackgroundToolbarOptions(DrawOptions drawOptions,
      String auth_token, bool online) async {
    BackgroundOptions backgroundOptions = drawOptions as BackgroundOptions;
    if (online) {
      await http.post(
          Uri.parse(
              (settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                  "/toolbar-options/background/update"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + auth_token,
          },
          body: jsonEncode(new EncodeBackgroundOptions(
              backgroundOptions.strokeWidth,
              backgroundOptions.selectedBackground)));
    } else {
      settingsStorage.setItem(
          "background-options",
          jsonEncode(new EncodeBackgroundOptions(
              backgroundOptions.strokeWidth,
              backgroundOptions.selectedBackground)));
    }
  }
}
