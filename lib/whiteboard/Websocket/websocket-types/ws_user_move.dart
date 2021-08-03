class WSUserMove {
  String uuid;
  double offset_dx;
  double offset_dy;
  double scale;

  WSUserMove.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'scale': scale
    };
  }

  WSUserMove(this.uuid, this.offset_dx, this.offset_dy, this.scale);
}
