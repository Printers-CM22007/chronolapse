import 'package:chronolapse/backend/video_stitcher/stitcher_options.dart';

class VideoStitcher {
  StitcherOptions options;
  bool isRunning;
  int framesProcessed;

  VideoStitcher(StitcherOptions opt)
      : options = opt,
        isRunning = false,
        framesProcessed = 0;
}
