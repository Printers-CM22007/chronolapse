import 'dart:io';
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
