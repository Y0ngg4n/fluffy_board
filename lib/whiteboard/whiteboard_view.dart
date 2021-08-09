import 'dart:async';

import 'package:fluffy_board/dashboard/dashboard.dart';
import 'package:fluffy_board/dashboard/filemanager/file_manager_types.dart';
import 'package:fluffy_board/utils/export_utils.dart';
import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:fluffy_board/whiteboard/infinite_canvas.dart';
import 'package:fluffy_board/whiteboard/texts_canvas.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/api/get_toolbar_options.dart';
import 'package:fluffy_board/whiteboard/appbar/connected_users.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/background_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/eraser_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/figure_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/higlighter_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/pencil_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/straight_line_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/text_toolbar.dart';
import 'package:fluffy_board/whiteboard/overlays/zoom.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'whiteboard_view_data_manager.dart';
import 'appbar/bookmark_manager.dart';
import 'overlays/toolbar.dart' as Toolbar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnSaveOfflineWhiteboard = Function();

class WhiteboardView extends StatefulWidget {
  final Whiteboard? whiteboard;
  final ExtWhiteboard? extWhiteboard;
  final OfflineWhiteboard? offlineWhiteboard;
  final String authToken;
  final String id;
  final bool online;

  WhiteboardView(this.whiteboard, this.extWhiteboard, this.offlineWhiteboard,
      this.authToken, this.id, this.online);

  @override
  _WhiteboardViewState createState() => _WhiteboardViewState();
}

class _WhiteboardViewState extends State<WhiteboardView> {
  Toolbar.ToolbarOptions? toolbarOptions;
  ZoomOptions zoomOptions = new ZoomOptions(1);
  List<Upload> uploads = [];
  List<TextItem> texts = [];
  List<Bookmark> bookmarks = [];
  List<Scribble> scribbles = [];
  Offset offset = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  WebsocketConnection? websocketConnection;
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  String toolbarLocation = "left";
  Set<ConnectedUser> connectedUsers = Set.of([]);
  ConnectedUser? followingUser;
  bool stylusOnly = false;
  late Timer autoSaveTimer;

  @override
  void initState() {
    super.initState();
    if (widget.offlineWhiteboard == null && widget.online) {
      try {
        websocketConnection = WebsocketConnection.getInstance(
          id: widget.id,
          whiteboard: widget.whiteboard == null
              ? widget.extWhiteboard!.original
              : widget.whiteboard!.id,
          authToken: widget.authToken,
          onScribbleAdd: (scribble) {
            setState(() {
              scribbles.add(scribble);
              ScreenUtils.calculateScribbleBounds(scribble);
              ScreenUtils.bakeScribble(scribble, zoomOptions.scale);
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
                  ScreenUtils.calculateScribbleBounds(scribble);
                  ScreenUtils.bakeScribble(scribble, zoomOptions.scale);
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
          },
          onUploadAdd: (upload) {
            setState(() {
              uploads.add(upload);
            });
          },
          onUploadUpdate: (upload) {
            setState(() {
              // Reverse Upload Search for better Performance
              for (int i = uploads.length - 1; i >= 0; i--) {
                if (uploads[i].uuid == upload.uuid) {
                  uploads[i].offset = upload.offset;
                  break;
                }
              }
            });
          },
          onUploadImageDataUpdate: (upload) {
            setState(() {
              // Reverse Upload Search for better Performance
              for (int i = uploads.length - 1; i >= 0; i--) {
                if (uploads[i].uuid == upload.uuid) {
                  uploads[i].uint8List = upload.uint8List;
                  uploads[i].image = upload.image;
                  break;
                }
              }
            });
          },
          onUploadDelete: (id) {
            setState(() {
              // Reverse Scribble Search for better Performance
              for (int i = uploads.length - 1; i >= 0; i--) {
                if (uploads[i].uuid == id) {
                  uploads.removeAt(i);
                  break;
                }
              }
            });
          },
          onTextItemAdd: (textItem) {
            setState(() {
              texts.add(textItem);
            });
          },
          onTextItemUpdate: (textItem) {
            setState(() {
              // Reverse TextItem Search for better Performance
              for (int i = texts.length - 1; i >= 0; i--) {
                if (texts[i].uuid == textItem.uuid) {
                  texts[i] = textItem;
                  break;
                }
              }
            });
          },
          onUserJoin: (connectedUser) {
            setState(() {
              bool exists = false;
              for (ConnectedUser cu in connectedUsers) {
                if (cu.uuid == connectedUser.uuid) {
                  exists = true;
                  break;
                }
              }
              if (!exists) connectedUsers.add(connectedUser);
            });
          },
          onUserMove: (connectedUserMove) {
            setState(() {
              for (int i = 0; i < connectedUsers.length; i++) {
                if (connectedUsers.elementAt(i).uuid ==
                    connectedUserMove.uuid) {
                  connectedUsers.elementAt(i).offset = connectedUserMove.offset;
                  break;
                }
              }
              if (followingUser != null) {
                this.offset = followingUser!.offset;
                this.zoomOptions.scale = followingUser!.scale;
              }
            });
          },
          onUserCursorMove: (connectedUserCursorMove) {
            setState(() {
              for (int i = 0; i < connectedUsers.length; i++) {
                if (connectedUsers.elementAt(i).uuid ==
                    connectedUserCursorMove.uuid) {
                  connectedUsers.elementAt(i).cursorOffset =
                      connectedUserCursorMove.offset;
                  break;
                }
              }
            });
          },
          onBookmarkAdd: (bookmark) {
            setState(() {
              bookmarks.add(bookmark);
            });
          },
          onBookmarkUpdate: (bookmark) {
            setState(() {
              // Reverse TextItem Search for better Performance
              for (int i = bookmarks.length - 1; i >= 0; i--) {
                if (bookmarks[i].uuid == bookmark.uuid) {
                  bookmarks[i] = bookmark;
                  break;
                }
              }
            });
          },
          onBookmarkDelete: (uuid) {
            setState(() {
              // Reverse Scribble Search for better Performance
              for (int i = bookmarks.length - 1; i >= 0; i--) {
                if (bookmarks[i].uuid == uuid) {
                  bookmarks.removeAt(i);
                  break;
                }
              }
            });
          },
        );
      } catch (e) {
        Navigator.pop(context);
      }
      // WidgetsBinding.instance!
      //     .addPostFrameCallback((_) => _createToolbars(context));
    }
    autoSaveTimer = Timer.periodic(
        Duration(seconds: 30), (timer) => saveOfflineWhiteboard());
    settingsStorage.ready.then((value) => setState(() {
          toolbarLocation =
              settingsStorage.getItem("toolbar-location") ?? "left";
          _getToolBarOptions();
        }));
    _getWhiteboardData();
  }

  @override
  void dispose() {
    super.dispose();
    autoSaveTimer.cancel();
    if (websocketConnection != null) websocketConnection!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      toolbarLocation = settingsStorage.getItem("toolbar-location") ?? "left";
      stylusOnly = settingsStorage.getItem("stylus-only") ?? false;
    });
    AppBar appBar = AppBar(
        title: Text(
          widget.whiteboard == null
              ? widget.extWhiteboard == null
                  ? widget.offlineWhiteboard!.name
                  : widget.extWhiteboard!.name
              : widget.whiteboard!.name,
        ),
        actions: [
          ConnectedUsers(
            scale: zoomOptions.scale,
            offset: offset,
            connectedUsers: connectedUsers,
            onTeleport: (offset, scale) {
              setState(() {
                this.offset = offset;
                this.zoomOptions.scale = scale;
              });
            },
            onFollowing: (connectedUser) {
              setState(() {
                followingUser = connectedUser;
              });
            },
          ),
          PopupMenuButton(
              onSelected: (value) => {
                    setState(() {
                      switch (value) {
                        case 0:
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .tryingExportImage)));
                          ExportUtils.exportPNG(
                              scribbles,
                              uploads,
                              texts,
                              toolbarOptions!,
                              new Offset(ScreenUtils.getScreenWidth(context),
                                  ScreenUtils.getScreenHeight(context)),
                              offset,
                              zoomOptions.scale);
                          break;
                        case 1:
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .tryingExportPDF)));
                          ExportUtils.exportPDF(
                              scribbles,
                              uploads,
                              texts,
                              toolbarOptions!,
                              new Offset(ScreenUtils.getScreenWidth(context),
                                  ScreenUtils.getScreenHeight(context)),
                              offset,
                              zoomOptions.scale);
                          break;
                        case 2:
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .tryingExportScreenSizeImage)));
                          ExportUtils.exportScreenSizePNG(
                              scribbles,
                              uploads,
                              texts,
                              toolbarOptions!,
                              new Offset(ScreenUtils.getScreenWidth(context),
                                  ScreenUtils.getScreenHeight(context)),
                              offset,
                              zoomOptions.scale);
                          break;
                      }
                    })
                  },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.exportImage), value: 0),
                    PopupMenuItem(child: Text(AppLocalizations.of(context)!.exportPDF), value: 1),
                    PopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.exportScreenSizeImage),
                        value: 2),
                  ],
              icon: Icon(Icons.import_export)),
          IconButton(
              onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookmarkManager(
                                  onBookMarkRefresh: (refreshController) async {
                                    await WhiteboardViewDataManager
                                        .getBookmarks(
                                            refreshController,
                                            widget.authToken,
                                            widget.whiteboard,
                                            widget.extWhiteboard,
                                            widget.offlineWhiteboard,
                                            (bookmarks) {
                                      setState(() {
                                        this.bookmarks = bookmarks;
                                      });
                                    });
                                  },
                                  authToken: widget.authToken,
                                  online: widget.online,
                                  onBookMarkTeleport: (offset, scale) => {
                                    setState(() {
                                      this.offset = offset;
                                      this.zoomOptions.scale = scale;
                                    })
                                  },
                                  bookmarks: bookmarks,
                                  offset: offset,
                                  scale: zoomOptions.scale,
                                  websocketConnection: websocketConnection,
                                )))
                  },
              icon: Icon(Icons.bookmark)),
          PopupMenuButton(
              onSelected: (value) => {
                    setState(() {
                      if (value.toString().startsWith("location-")) {
                        value = value.toString().replaceFirst("location-", "");
                        settingsStorage.setItem("toolbar-location", value);
                        toolbarLocation = value.toString();
                      } else if (value.toString() == "stylus-only") {
                        settingsStorage.setItem("stylus-only",
                            !(settingsStorage.getItem("stylus-only") ?? false));
                      } else if (value.toString() == "points-simplify") {
                        settingsStorage.setItem(
                            "points-simplify",
                            !(settingsStorage.getItem("points-simplify") ??
                                true));
                      } else if (value.toString() == "points-to-image") {
                        settingsStorage.setItem(
                            "points-to-image",
                            !(settingsStorage.getItem("points-to-image") ??
                                true));
                      } else if (value.toString() == "user-cursors") {
                        settingsStorage.setItem("user-cursors",
                            !(settingsStorage.getItem("user-cursors") ?? true));
                      }
                    })
                  },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.leftToolbar),
                        checked: toolbarLocation == "left" ? true : false,
                        value: "location-left"),
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.rightToolbar),
                        checked: toolbarLocation == "right" ? true : false,
                        value: "location-right"),
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.topToolbar),
                        checked: toolbarLocation == "top" ? true : false,
                        value: "location-top"),
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.bottomToolbar),
                        checked: toolbarLocation == "bottom" ? true : false,
                        value: "location-bottom"),
                    PopupMenuDivider(),
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.stylusOnly),
                        checked: stylusOnly,
                        value: "stylus-only"),
                    PopupMenuDivider(),
                    CheckedPopupMenuItem(
                        child:
                            Text(AppLocalizations.of(context)!.optimizePoints),
                        checked:
                            settingsStorage.getItem("points-simplify") ?? true,
                        value: "points-simplify"),
                    CheckedPopupMenuItem(
                        child:
                            Text(AppLocalizations.of(context)!.pointsToImages),
                        checked:
                            settingsStorage.getItem("points-to-image") ?? true,
                        value: "points-to-image"),
                    CheckedPopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.displayCursors),
                        checked:
                            settingsStorage.getItem("user-cursors") ?? true,
                        value: "user-cursors")
                  ])
        ]);

    if (toolbarOptions == null) {
      return Dashboard.loading(widget.whiteboard == null
          ? widget.extWhiteboard == null
              ? widget.offlineWhiteboard!.name
              : widget.extWhiteboard!.name
          : widget.whiteboard!.name);
    }

    Widget toolbar = (widget.whiteboard != null ||
            (widget.extWhiteboard != null && widget.extWhiteboard!.edit) ||
            widget.offlineWhiteboard != null)
        ? (Toolbar.Toolbar(
            toolbarLocation: toolbarLocation,
            onSaveOfflineWhiteboard: () => saveOfflineWhiteboard(),
            texts: texts,
            scribbles: scribbles,
            toolbarOptions: toolbarOptions!,
            zoomOptions: zoomOptions,
            offset: offset,
            sessionOffset: _sessionOffset,
            uploads: uploads,
            websocketConnection: websocketConnection,
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
            onUploadsChange: (uploads) {
              setState(() {
                this.uploads = uploads;
              });
            },
            onTextItemsChange: (textItems) {
              setState(() {
                this.texts = textItems;
              });
            },
          ))
        : Container();

    return Scaffold(
        appBar: (appBar),
        body: Stack(children: [
          Container(
            decoration: followingUser == null
                ? BoxDecoration()
                : BoxDecoration(
                    border: Border.all(color: followingUser!.color, width: 10)),
            child: InfiniteCanvasPage(
              connectedUsers: connectedUsers,
              stylusOnly: stylusOnly,
              id: widget.id,
              onSaveOfflineWhiteboard: () => saveOfflineWhiteboard(),
              authToken: widget.authToken,
              websocketConnection: websocketConnection,
              toolbarOptions: toolbarOptions!,
              zoomOptions: zoomOptions,
              appBarHeight: appBar.preferredSize.height,
              onScribblesChange: (scribbles) {
                setState(() {
                  this.scribbles = scribbles;
                });
              },
              onUploadsChange: (uploads) {
                setState(() {
                  this.uploads = uploads;
                });
              },
              onTextItemsChange: (textItems) {
                setState(() {
                  this.texts = textItems;
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
              onDontFollow: () {
                setState(() {
                  this.followingUser = null;
                });
              },
            ),
          ),
          TextsCanvas(
            websocketConnection: websocketConnection,
            sessionOffset: _sessionOffset,
            offset: offset,
            texts: texts,
            toolbarOptions: toolbarOptions!,
          ),
          toolbar,
          ZoomView(
            toolbarLocation: toolbarLocation,
            zoomOptions: zoomOptions,
            offset: offset,
            onChangedZoomOptions: (zoomOptions) {
              setState(() {
                this.zoomOptions = zoomOptions;
              });
            },
            onChangedOffset: (offset) {
              setState(() {
                this.offset = offset;
                WebsocketSend.sendUserMove(
                    offset, widget.id, zoomOptions.scale, websocketConnection);
              });
            },
          )
        ]));
  }

  Future _getToolBarOptions() async {
    PencilOptions pencilOptions = await GetToolbarOptions.getPencilOptions(
        widget.authToken, widget.online);
    HighlighterOptions highlighterOptions =
        await GetToolbarOptions.getHighlighterOptions(
            widget.authToken, widget.online);
    EraserOptions eraserOptions = await GetToolbarOptions.getEraserOptions(
        widget.authToken, widget.online);
    StraigtLineOptions straightLineOptions =
        await GetToolbarOptions.getStraightLineOptions(
            widget.authToken, widget.online);
    TextOptions textItemOptions = await GetToolbarOptions.getTextItemOptions(
        widget.authToken, widget.online);
    FigureOptions figureOptions = await GetToolbarOptions.getFigureOptions(
        widget.authToken, widget.online);
    BackgroundOptions backgroundOptions =
        await GetToolbarOptions.getBackgroundOptions(
            widget.authToken, widget.online);
    print("TextItem: " + textItemOptions.currentColor.toString());
    setState(() {
      toolbarOptions = new Toolbar.ToolbarOptions(
          Toolbar.SelectedTool.move,
          pencilOptions,
          highlighterOptions,
          straightLineOptions,
          eraserOptions,
          figureOptions,
          textItemOptions,
          backgroundOptions,
          false,
          Toolbar.SettingsSelected.none,
          websocketConnection);
    });
  }

  Future _getWhiteboardData() async {
    if (websocketConnection != null) {
      await WhiteboardViewDataManager.getScribbles(
          widget.authToken, widget.whiteboard, widget.extWhiteboard,
          (Scribble newScribble) {
        setState(() {
          scribbles.add(newScribble);
        });
      }, zoomOptions);
      await WhiteboardViewDataManager.getUploads(
          widget.authToken, widget.whiteboard, widget.extWhiteboard,
          (Upload newUpload) {
        setState(() {
          uploads.add(newUpload);
        });
      }, zoomOptions);
      await WhiteboardViewDataManager.getTextItems(
          widget.authToken, widget.whiteboard, widget.extWhiteboard,
          (TextItem textItem) {
        setState(() {
          texts.add(textItem);
        });
      });
      await WhiteboardViewDataManager.getBookmarks(
          null,
          widget.authToken,
          widget.whiteboard,
          widget.extWhiteboard,
          widget.offlineWhiteboard, (List<Bookmark> bookmarks) {
        setState(() {
          this.bookmarks = bookmarks;
        });
      });
    }
    if (widget.offlineWhiteboard != null) {
      print("Get Offset" + widget.offlineWhiteboard!.offset.toString());
      print("Get scale" + widget.offlineWhiteboard!.scale.toString());
      setState(() {
        scribbles = widget.offlineWhiteboard!.scribbles.list;
        uploads = widget.offlineWhiteboard!.uploads.list;
        texts = widget.offlineWhiteboard!.texts.list;
        bookmarks = widget.offlineWhiteboard!.bookmarks.list;
        offset = widget.offlineWhiteboard!.offset;
        zoomOptions.scale = widget.offlineWhiteboard!.scale;
      });
    }
  }

  saveOfflineWhiteboard() async {
    if (widget.offlineWhiteboard == null) return;
    await fileManagerStorage.setItem(
        "offline_whiteboard-" + widget.offlineWhiteboard!.uuid,
        new OfflineWhiteboard(
                widget.offlineWhiteboard!.uuid,
                widget.offlineWhiteboard!.directory,
                widget.offlineWhiteboard!.name,
                new Uploads(uploads),
                new TextItems(texts),
                new Scribbles(scribbles),
                new Bookmarks(bookmarks),
                offset + _sessionOffset,
                zoomOptions.scale)
            .toJSONEncodable());
    print("Save");
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

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHexWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
