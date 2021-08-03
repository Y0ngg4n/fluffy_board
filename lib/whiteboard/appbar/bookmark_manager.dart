import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/appbar/add_bookmark.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'rename_bookmark.dart';

typedef OnBookMarkTeleport = Function(Offset, double);
typedef OnBookMarkRefresh = Function(RefreshController);

class BookmarkManager extends StatefulWidget {
  final String authToken;
  final OnBookMarkTeleport onBookMarkTeleport;
  final List<Bookmark> bookmarks;
  final Offset offset;
  final double scale;
  final WebsocketConnection? websocketConnection;
  final bool online;
  final OnBookMarkRefresh onBookMarkRefresh;

  BookmarkManager(
      {required this.authToken,
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
                                  widget.authToken,
                                  widget.online,
                                  widget.websocketConnection,
                                  widget.offset,
                                  widget.scale,
                                  refreshController,
                                  (bookmark){
                                    widget.bookmarks.add(bookmark);
                                  }
                              )));
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
                child: ListView.separated(
                  itemCount: widget.bookmarks.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(widget.bookmarks[index].name),
                      onTap: () {
                        widget.onBookMarkTeleport(
                            widget.bookmarks[index].offset,
                            widget.bookmarks[index].scale);
                        Navigator.pop(context);
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RenameBookmark(
                                          widget.authToken,
                                          widget.online,
                                          widget.websocketConnection,
                                          refreshController,
                                          widget.bookmarks[index])));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              WebsocketSend.sendBookmarkDelete(
                                  widget.bookmarks[index],
                                  widget.websocketConnection);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                )),
          ),
        ])));
  }
}
