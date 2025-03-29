import 'dart:math';
import 'dart:typed_data';

Uint8List generateRandomBytes(int length) {
  final random = Random();
  final bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}
