import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImagePreprocessResult {
  const ImagePreprocessResult({
    required this.bytes,
    required this.compressionRatio,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final double compressionRatio;
  final int width;
  final int height;

  bool get isWithinLimit => bytes.lengthInBytes <= 5 * 1024 * 1024;
}

Future<ImagePreprocessResult> preprocessForUpload(
  Uint8List input, {
  int targetWidth = 1920,
}) async {
  final originalLength = input.lengthInBytes;
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw ArgumentError('Unsupported image format');
  }

  final cropped = _autoCrop(decoded);
  final denoised = img.gaussianBlur(cropped, 1);
  final gray = img.grayscale(denoised);
  final resized = img.copyResize(
    gray,
    width: targetWidth,
    interpolation: img.Interpolation.cubic,
  );
  final jpg = img.encodeJpg(resized, quality: 85);
  final ratio = originalLength / jpg.length;
  return ImagePreprocessResult(
    bytes: Uint8List.fromList(jpg),
    compressionRatio: ratio,
    width: resized.width,
    height: resized.height,
  );
}

img.Image _autoCrop(img.Image source) {
  final int marginX = max(8, (source.width * 0.02).round());
  final int marginY = max(8, (source.height * 0.02).round());
  return img.copyCrop(
    source,
    x: marginX,
    y: marginY,
    width: source.width - marginX * 2,
    height: source.height - marginY * 2,
  );
}
