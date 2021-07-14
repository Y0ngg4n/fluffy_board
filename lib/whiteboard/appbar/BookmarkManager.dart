import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:fluffy_board/whiteboard/appbar/AddBookMark.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef OnBookMarkTeleport = Function(Offset, double);
typedef OnBookMarkRefresh = Function(RefreshController);

class BookmarkManager extends StatefulWidget {
  String auth_token;
  OnBookMarkTeleport onBookMarkTeleport;
  List<Bookmark> bookmarks;
  Offset offset;
  double scale;
  WebsocketConnection? websocketConnection;
  bool online;
  OnBookMarkRefresh onBookMarkRefresh;

  BookmarkManager(
      {required this.auth_token,
      required this.online,
      required this.onBookMarkTeleport,
      required this.bookmarks,
      required this.offset,
      required this.scale,
      required this.websocketConnection,
      required this.onBookMarkRefresh});

  @override
  _BookmarkManagerState createState() => _BookmarkManagerState();
}

class _BookmarkManagerState extends State<BookmarkManager> {
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    List<Widget> bookmarkWidgets = [];
    for (Bookmark bookmark in widget.bookmarks) {
      bookmarkWidgets.add(ListTile(
        title: Text(bookmark.name),
        onTap: () {
          widget.onBookMarkTeleport(bookmark.offset, bookmark.scale);
          Navigator.pop(context);
        },
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            WebsocketSend.sendBookmarkDelete(
                bookmark, widget.websocketConnection);
          },
        ),
      ));
    }
    return Scaffold(
        appBar: AppBar(title: Text("Bookmarks")),
        body: Container(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddBookmark(
                                  widget.auth_token,
                                  widget.online,
                                  widget.websocketConnection,
                                  widget.offset,
                                  widget.scale,
                                  refreshController)));
                    },
                    child: Text("Create Bookmark"))
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: refreshController,
                onRefresh: () async =>
                    {await widget.onBookMarkRefresh(refreshController)},
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: bookmarkWidgets,
                )),
          ),
        ])));
  }
}
