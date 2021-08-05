import 'dart:typed_data';
import 'package:image/image.dart' as IMG;

class ImageUtils {
  static Uint8List resizeImage(Uint8List data, double scaleFactor) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!,
        width: (img.width * scaleFactor).toInt(),
        height: (img.height * scaleFactor).toInt());
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }

  static Uint8List rotateImage(Uint8List data, double rotateFactor) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyRotate(img!, rotateFactor);
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }
}