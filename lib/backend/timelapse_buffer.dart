import 'dart:typed_data';

import 'package:opencv_dart/opencv.dart' as cv2;
import 'dart:async';
import 'dart:isolate';

class TimelapseBuffer {
  late SendPort _sendPort;
  final Completer<void> _isolateReady = Completer.sync();
  late ReceivePort _receivePort;

  List<cv2.Mat> frames = [];

  Future<void> beginLoadingTimelapse(String timelapsePath, int nFrames) async {
    _receivePort = ReceivePort();
    _receivePort.listen(_handleResponsesFromIsolate);
    await Isolate.spawn(_startRemoteIsolate, _receivePort.sendPort);

    await _isolateReady.future;
    Map<String, dynamic> message = {
      "nFrames": nFrames,
      "timelapsePath": timelapsePath
    };
    _sendPort.send(message);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
    } else if (message is (bool, Uint8List)) {
      var decode = cv2.imdecode(message.$2, cv2.IMREAD_COLOR);

      frames.add(decode);
    } else if (message == "stop") {
      _receivePort.close();
    }
  }

  static void _startRemoteIsolate(SendPort port) {
    final receivePort = ReceivePort();
    port.send(receivePort.sendPort);

    final Completer<void> beginProcessing = Completer.sync();

    late int nFrames;
    late String timelapsePath;

    Future(() async {
      await beginProcessing.future;

      for(int i = 0; i < nFrames; i++) {
        var img = await cv2.imreadAsync(timelapsePath + i.toString() + ".png");
        var encoded = cv2.imencode('.png', img);

        port.send(encoded);
      }

      port.send("stop");

      receivePort.close();
      Isolate.exit();
    });

    receivePort.listen((dynamic message) async {
      if (message is Map<String, dynamic>) {
        nFrames = message["nFrames"];
        timelapsePath = message["timelapsePath"];
        beginProcessing.complete();
      }
    });
  }

  Future<cv2.Mat> retrieveFrame(int frame) async {
    await _isolateReady.future;

    while (frames.length <= frame) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    return frames[frame];
  }
}