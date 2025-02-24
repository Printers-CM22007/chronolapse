import 'package:opencv_dart/opencv.dart' as cv2;
import 'native_image.dart';
import 'dart:async';
import 'dart:isolate';

class TimelapseBuffer {
  late SendPort _sendPort;
  final Completer<void> _isolateReady = Completer.sync();

  List<cv2.Mat> frames = List.empty();
  int nFrames = 0;

  Future<void> spawn() async {
    final recievePort = ReceivePort();
    recievePort.listen(_handleResponsesFromIsolate);
    await Isolate.spawn(_startRemoteIsolate, recievePort.sendPort);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
    } else {
      print("message is $message");
      //var img = NativeImage();
      //var img = cv2.imread(message);
      //frames.add(img);
      //nFrames++;
      //_sendPort.send("yo");
    }
  }

  static void _startRemoteIsolate(SendPort port) {
    final recievePort = ReceivePort();
    port.send(recievePort.sendPort);

    Future(() async {
      while (true) {
        // This simulates some background task running
        //await Future.delayed(Duration(milliseconds: 150));
        //print("Background task is running...");
      
      }
    });

    recievePort.listen((dynamic message) async {
      if (message is String) {
        final transformed = message + "_bruh";
        port.send(transformed);
      }
    });


  }

  Future<void> doStuff(String string) async {
    await _isolateReady.future;
    _sendPort.send(string);
  }
}