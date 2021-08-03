class WSUserMove {
  String uuid;
  double offsetDx;
  double offsetDy;
  double scale;

  WSUserMove.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        offsetDx = json['offset_dx'].toDouble(),
        offsetDy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();

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
