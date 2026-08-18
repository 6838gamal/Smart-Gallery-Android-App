import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Pure image-processing service, decoupled from the UI. All operations
/// return a new [img.Image] and never touch the source file.
class EditorService {
  EditorService._();
  static final EditorService instance = EditorService._();

  Future<img.Image> load(File file) async {
    final bytes = await file.readAsBytes();
    return img.decodeImage(bytes)!;
  }

  img.Image rotate(img.Image src, {double degrees = 90}) {
    if (degrees == 90) return img.copyRotate(src, angle: 90);
    if (degrees == -90) return img.copyRotate(src, angle: -90);
    if (degrees == 180) return img.copyRotate(src, angle: 180);
    return src;
  }

  img.Image flipHorizontal(img.Image src) => img.flipHorizontal(src);
  img.Image flipVertical(img.Image src) => img.flipVertical(src);

  img.Image crop(img.Image src, int x, int y, int w, int h) =>
      img.copyCrop(src, x: x, y: y, width: w, height: h);

  img.Image adjust({
    required img.Image src,
    double brightness = 0,
    double contrast = 0,
    double saturation = 0,
  }) {
    var out = src;
    if (brightness != 0) out = img.adjustColor(out, brightness: brightness);
    if (contrast != 0) out = img.adjustColor(out, contrast: contrast);
    if (saturation != 0) out = img.adjustColor(out, saturation: saturation);
    return out;
  }

  /// Preset filters implemented as color adjustments.
  img.Image applyFilter(img.Image src, EditorFilter filter) {
    switch (filter) {
      case EditorFilter.none:
        return src;
      case EditorFilter.grayscale:
        return img.grayscale(src);
      case EditorFilter.sepia:
        return img.sepia(src);
      case EditorFilter.invert:
        return img.invert(src);
    }
  }

  /// Saves as a new JPEG file in the pictures directory. Returns the path.
  Future<String> saveAsNew(img.Image image, String baseName) async {
    final dir = await getApplicationDocumentsDirectory();
    final out = p.join(dir.path, '${baseName}_edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final file = File(out);
    await file.writeAsBytes(img.encodeJpg(image, quality: 95));
    return out;
  }
}

enum EditorFilter { none, grayscale, sepia, invert }
