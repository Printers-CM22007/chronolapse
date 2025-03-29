import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as img;

class None {
  const None();
}

/// Slow (loads whole image)
Future<(int, int)> getImageDimensions(String imagePath) async {
  final file = File(imagePath);
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes)!;

  return (image.width, image.height);
}

/// Generate a random pastel-ish colour for feature points
(int, int, int) randomPastelColor() {
  final random = Random(DateTime.now().hashCode);

  return (
    random.nextInt(128) + 128,
    random.nextInt(128) + 128,
    random.nextInt(128) + 128
  );
}
