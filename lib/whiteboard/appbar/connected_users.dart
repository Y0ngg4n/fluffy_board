import 'package:flutter/material.dart';

class ConnectedUser {
  String uuid;
  String username;
  Color color;
  Offset offset;
  Offset cursorOffset;
  double scale;

  ConnectedUser(this.uuid, this.username, this.color, this.offset, this.cursorOffset, this.scale);
}

class ConnectedUserMove {
  String uuid;
  Offset offset;
  double scale;

  ConnectedUserMove(this.uuid, this.offset, this.scale);
}

class ConnectedUserCursorMove {
  String uuid;
  Offset offset;

  ConnectedUserCursorMove(this.uuid, this.offset);
}

typedef OnTeleport = Function(Offset, double);
typedef OnFollowing = Function(ConnectedUser);

class ConnectedUsers extends StatefulWidget {
  final Set<ConnectedUser> connectedUsers;
  final OnTeleport onTeleport;
  final OnFollowing onFollowing;
  final Offset offset;
  final double scale;

  ConnectedUsers(
      {required this.connectedUsers,
      required this.onTeleport,
      required this.onFollowing,
      required this.offset,
      required this.scale});

  @override
  _ConnectedUsersState createState() => _ConnectedUsersState();
}

class _ConnectedUsersState extends State<ConnectedUsers> {
  Offset? offsetBeforeTeleport;
  double? scaleBeforeTeleport;

  @override
  Widget build(BuildContext context) {
    List<Widget> avatars = [];
    for (ConnectedUser connectedUser in widget.connectedUsers) {
      avatars.add(PopupMenuButton(
        child: CircleAvatar(
          backgroundColor: connectedUser.color,
          child: Text(connectedUser.username),
        ),
        itemBuilder: (context) => [
          offsetBeforeTeleport == null
              ? PopupMenuItem(child: Text("Teleport"), value: 0)
              : PopupMenuItem(child: Text("Teleport back"), value: 1),
          PopupMenuItem(child: Text("Follow"), value: 2),
        ],
        onSelected: (value) {
          switch (value) {
            case 0:
              setState(() {
                offsetBeforeTeleport =
                    new Offset(widget.offset.dx, widget.offset.dy);
                scaleBeforeTeleport = widget.scale;
              });
              widget.onTeleport(connectedUser.offset, connectedUser.scale);
              break;
            case 1:
              widget.onTeleport(
                offsetBeforeTeleport!,
                scaleBeforeTeleport!
              );
              break;
            case 2:
              widget.onFollowing(connectedUser);
              break;
          }
        },
      ));
    }
    return Row(
      children: avatars,
    );
  }
}
