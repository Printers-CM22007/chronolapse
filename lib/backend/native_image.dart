import 'package:opencv_dart/opencv.dart' as cv;

class NativeImage {
  cv.Mat internal;

  NativeImage(String path) :
    internal = cv.imread(path) {
  }
}