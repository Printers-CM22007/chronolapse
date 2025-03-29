package com.example.chronolapse


import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import android.media.MediaCodec
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

import com.example.chronolapse.sixo.TimeLapseEncoder
import com.example.chronolapse.sixo.TextureRenderer

class MainActivity: FlutterActivity() {
    private val channel = "com.example.chronolapse/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "testFunction") {
                val count = call.argument<Int>("count")!!
                result.success(count + 1)
            } else if (call.method == "compileVideo") {
                val dirPath = call.argument<String>("framesDirPath")!!
                val outputPath = call.argument<String>("outputPath")!!
                val nFrames = call.argument<Int>("nFrames")!!
                val projectName = call.argument<String>("projectName")!!
                val frameRate = call.argument<Int>("frameRate")!!
                val bitRate = call.argument<Int>("bitRate")!!
                try {
                    var outputPath = compileVideo(dirPath, outputPath, nFrames, projectName, frameRate, bitRate)
                    result.success(outputPath)
                } catch (e: Exception) {
                    Log.e("Chronolapse: VideoCompilation", "compileVideo encountered an exception", e)
                    result.error("Chronolapse: VideoCompilation", "compileVideo encountered an exception", e)
                }

            } else {
                result.notImplemented()
            }
        }
    }

    private fun compileVideo(dirPath: String, outputPath: String, nFrames: Int, projectName: String, frameRate: Int, bitRate: Int): String {
        val uriList: MutableList<Uri> = ArrayList()
        for (i in 0..nFrames) {
            val file = File("$dirPath/$i.png")

            val uri = Uri.fromFile(file);
            uriList.add(uri)
        }
        TimeLapseEncoder(frameRate, bitRate).encode("{cacheDir.path}/$projectName.mp4", uriList, contentResolver);

        return "${cacheDir.path}/output.mp4"
    }
}
