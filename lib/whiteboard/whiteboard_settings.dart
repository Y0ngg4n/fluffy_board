import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:localstorage/localstorage.dart';

enum ToolbarLocation { left, right, top, bottom }

typedef OnChangedWhiteboardSettings = Function();

class WhiteboardSettings extends StatefulWidget {
  @override
  _WhiteboardSettingsState createState() => _WhiteboardSettingsState();
}

class _WhiteboardSettingsState extends State<WhiteboardSettings> {
  final LocalStorage settingsStorage = new LocalStorage('settings');
  ToolbarLocation? selectedToolbarLocation = ToolbarLocation.left;
  static const double titleFontSize = 20;
  bool stylusOnly = false;
  bool optimizePoints = true;
  bool optimizePointsToImage = true;
  bool showUserCursors = true;
  bool showZoomPanel = true;
  bool showMinimap = true;

  @override
  void initState() {
    super.initState();
    settingsStorage.ready.then((value) => setState(() {
          selectedToolbarLocation = getToolbarLocation(
              settingsStorage.getItem("toolbar-location") ?? "left");
          stylusOnly = settingsStorage.getItem("stylus-only") ?? false;
          optimizePoints = settingsStorage.getItem("points-simplify") ?? true;
          optimizePointsToImage =
              settingsStorage.getItem("points-to-image") ?? true;
          showUserCursors =
              settingsStorage.getItem("user-cursors") ?? true;
          showZoomPanel =
              settingsStorage.getItem("zoom-panel") ?? true;
          showMinimap = settingsStorage.getItem("minimap") ?? true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    Widget toolbarLocation = (Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.toolbarLocation,
          style: TextStyle(fontSize: titleFontSize),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Radio<ToolbarLocation>(
                groupValue: selectedToolbarLocation,
                value: ToolbarLocation.top,
                onChanged: (value) => setSelectedToolbarLocation(value),
              ),
              Text(AppLocalizations.of(context)!.topToolbar)
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [
                  Radio<ToolbarLocation>(
                    groupValue: selectedToolbarLocation,
                    value: ToolbarLocation.left,
                    onChanged: (value) => setSelectedToolbarLocation(value),
                  ),
                  Text(AppLocalizations.of(context)!.leftToolbar)
                ]),
                Row(children: [
                  Radio<ToolbarLocation>(
                    groupValue: selectedToolbarLocation,
                    value: ToolbarLocation.right,
                    onChanged: (value) => setSelectedToolbarLocation(value),
                  ),
                  Text(AppLocalizations.of(context)!.rightToolbar)
                ])
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Radio<ToolbarLocation>(
                groupValue: selectedToolbarLocation,
                value: ToolbarLocation.bottom,
                onChanged: (value) => setSelectedToolbarLocation(value),
              ),
              Text(AppLocalizations.of(context)!.bottomToolbar)
            ]),
          ],
        ),
      ),
    ]));

    Widget stylusSettings = (Column(children: [
      Text(AppLocalizations.of(context)!.stylusSettings,
          style: TextStyle(fontSize: titleFontSize)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.stylusOnly),
          Switch(
            value: stylusOnly,
            onChanged: (value) => {
              setState(() {
                stylusOnly = value;
                settingsStorage.setItem("stylus-only", value);
              })
            },
          )
        ],
      )
    ]));

    Widget optimizations = Column(
      children: [
        Text(AppLocalizations.of(context)!.optimizations,
            style: TextStyle(fontSize: titleFontSize)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.optimizePoints),
            Switch(
              value: optimizePoints,
              onChanged: (value) => {
                setState(() {
                  this.optimizePoints = value;
                  settingsStorage.setItem("points-simplify", value);
                })
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.optimizePoints),
            Switch(
              value: optimizePointsToImage,
              onChanged: (value) => {
                setState(() {
                  this.optimizePointsToImage = value;
                  settingsStorage.setItem("points-to-image", value);
                })
              },
            )
          ],
        )
      ],
    );

    Widget showSettings = Column(
      children: [
        Text(AppLocalizations.of(context)!.showSettings,
            style: TextStyle(fontSize: titleFontSize)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.displayCursors),
            Switch(
              value: showUserCursors,
              onChanged: (value) => {
                setState(() {
                  this.showUserCursors = value;
                  settingsStorage.setItem("user-cursors", value);
                })
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.showZoomPanel),
            Switch(
              value: showZoomPanel,
              onChanged: (value) => {
                setState(() {
                  this.showZoomPanel = value;
                  settingsStorage.setItem("zoom-panel", value);
                })
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.showMinimap),
            Switch(
              value: showMinimap,
              onChanged: (value) => {
                setState(() {
                  this.showMinimap = value;
                  settingsStorage.setItem("minimap", value);
                })
              },
            )
          ],
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.whiteboardSettings)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              toolbarLocation,
              Divider(),
              stylusSettings,
              Divider(),
              optimizations,
              Divider(),
              showSettings
            ],
          ),
        ));
  }

  ToolbarLocation getToolbarLocation(String location) {
    switch (location) {
      case "left":
        return ToolbarLocation.left;
      case "right":
        return ToolbarLocation.right;
      case "top":
        return ToolbarLocation.top;
      case "bottom":
        return ToolbarLocation.bottom;
      default:
        return ToolbarLocation.left;
    }
  }

  String getToolbarLocationString(ToolbarLocation location) {
    switch (location) {
      case ToolbarLocation.left:
        return "left";
      case ToolbarLocation.right:
        return "right";
      case ToolbarLocation.top:
        return "top";
      case ToolbarLocation.bottom:
        return "bottom";
      default:
        return "left";
    }
  }

  setSelectedToolbarLocation(ToolbarLocation? location) {
    if (location == null) return;
    setState(() {
      this.selectedToolbarLocation = location;
      settingsStorage.setItem(
          "toolbar-location", getToolbarLocationString(location));
    });
  }
}
