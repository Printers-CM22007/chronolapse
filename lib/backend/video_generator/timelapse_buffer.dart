import 'dart:typed_data';

import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:opencv_dart/opencv.dart' as cv2;
import 'dart:async';
import 'dart:isolate';

// Timelapse must not change on disk whilst being loaded, otherwise the list of frames will be incorrect
class TimelapseBuffer {
  late SendPort _sendPort;
  final Completer<void> _isolateReady = Completer.sync();
  late ReceivePort _receivePort;

  late ProjectTimelapseData timelapseData;
  List<cv2.Mat> _frames = [];

  Future<void> beginLoadingTimelapse(String projectName) async {
    _receivePort = ReceivePort();
    _receivePort.listen(_handleResponsesFromIsolate);
    await Isolate.spawn(_startRemoteIsolate, _receivePort.sendPort);

    final projectData = await TimelapseStore.getProject(projectName);

    await _isolateReady.future;
    Map<String, dynamic> message = {
      "projectName": projectName,
      "frameUUIDs": projectData.data.metaData.frames,
    };
    _sendPort.send(message);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
    } else if (message is (bool, Uint8List)) {
      var decode = cv2.imdecode(message.$2, cv2.IMREAD_COLOR);

      _frames.add(decode);
    } else if (message == "stop") {
      _receivePort.close();
    }
  }

  static void _startRemoteIsolate(SendPort port) {
    final receivePort = ReceivePort();
    port.send(receivePort.sendPort);

    final Completer<void> beginProcessing = Completer.sync();

    late String projectName;
    late List<String> frameUUIDs;

    Future(() async {
      await beginProcessing.future;

      for (int i = 0; i < frameUUIDs.length; i++) {
        var frameData = await TimelapseFrame.fromExisting(projectName, frameUUIDs[i]);
        var path = frameData.getFramePng().path;

        var img = await cv2.imreadAsync(path);
        var encoded = cv2.imencode('.png', img);

        port.send(encoded);
      }

      port.send("stop");

      receivePort.close();
      Isolate.exit();
    });

    receivePort.listen((dynamic message) async {
      if (message is Map<String, dynamic>) {
        projectName = message["projectName"];
        frameUUIDs = message["frameUUIDs"];

        beginProcessing.complete();
      }
    });
  }

  Future<cv2.Mat> retrieveFrame(int frame) async {
    await _isolateReady.future;

    while (_frames.length <= frame) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    return _frames[frame];
  }
}
