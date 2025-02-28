import 'package:opencv_dart/opencv.dart' as cv2;

class VideoCompiler {
  final cv2.VideoWriter _writer;

  VideoCompiler(String destination, String codec, double fps, int width, int height) :
      _writer = cv2.VideoWriter.fromFile(destination, codec, fps, (width, height))
  {}

  Future<void> WriteFrame(cv2.Mat frame) async {
    await _writer.writeAsync(frame);
  }

  void Finish() {
    _writer.release();
  }
}