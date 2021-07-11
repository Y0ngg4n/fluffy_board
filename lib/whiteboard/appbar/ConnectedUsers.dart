import 'package:flutter/material.dart';

class ConnectedUser {
  String uuid;
  String username;
  Color color;
  Offset offset;

  ConnectedUser(this.uuid, this.username, this.color, this.offset);
}

class ConnectedUserMove {
  String uuid;
  Offset offset;

  ConnectedUserMove(this.uuid, this.offset);
}


typedef OnTeleport = Function(Offset);

class ConnectedUsers extends StatefulWidget {
  Set<ConnectedUser> connectedUsers;
  OnTeleport onTeleport;

  ConnectedUsers({required this.connectedUsers, required this.onTeleport});

  @override
  _ConnectedUsersState createState() => _ConnectedUsersState();
}

class _ConnectedUsersState extends State<ConnectedUsers> {
  Offset? offsetBeforeTeleport;

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
              : PopupMenuItem(child: Text("Teleport back"), value: 0),
          PopupMenuItem(child: Text("Follow"), value: 2),
        ],
        onSelected: (value) {
          switch (value) {
            case 0:
              widget.onTeleport(connectedUser.offset);
              break;
            case 1:
              widget.onTeleport(offsetBeforeTeleport!);
              break;
            case 2:
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
