import 'package:uuid/uuid.dart';

class WSUserMove {
  String uuid;
  double offsetDx;
  double offsetDy;
  double scale;

  WSUserMove.fromJson(Map<String, dynamic> json)
      : uuid = (json['uuid'] ?? Uuid().v4()),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        scale = (json['scale'] ?? 1).toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'scale': scale
    };
  }

  WSUserMove(this.uuid, this.offsetDx, this.offsetDy, this.scale);
}

class WSUserCursorMove {
  String uuid;
  double offsetDx;
  double offsetDy;

  WSUserCursorMove.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? Uuid().v4(),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
    };
  }

  WSUserCursorMove(this.uuid, this.offsetDx, this.offsetDy);
}
