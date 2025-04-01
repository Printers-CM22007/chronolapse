package com.example.chronolapse


import android.net.Uri
import android.util.Log
import com.example.chronolapse.sixo.TimeLapseEncoder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val channel = "com.example.chronolapse/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "testFunction") {
                val count = call.argument<Int>("count")!!
                result.success(count + 1)
            } else if (call.method == "compileVideo") {
                val frameDir = call.argument<String>("frameDir")!!
                val frameCount = call.argument<Int>("frameCount")!!
                val outputPath = call.argument<String>("outputPath")!!
                val frameRate = call.argument<Int>("frameRate")!!
                val bitRate = call.argument<Int>("bitRate")!!
                try {
                    compileVideo(frameDir, frameCount, outputPath, frameRate, bitRate)
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

    private fun compileVideo(dirPath: String, frameCount: Int, outputPath: String, frameRate: Int, bitRate: Int): String {
        val uriList: MutableList<Uri> = ArrayList()
        for (i in 0 until frameCount) {
            val file = File("$dirPath/$i.png")

            val uri = Uri.fromFile(file);
            uriList.add(uri)
        }
        val encoder = TimeLapseEncoder(frameRate, bitRate)
        encoder.encode(outputPath, uriList, contentResolver)
        return outputPath
    }

    private fun testMediaCodec() {

        val uriList: MutableList<Uri> = ArrayList()
        for (i in 0..60) {
            val file = File(cacheDir, "CAT.png")

            val uri = Uri.fromFile(file);
            Log.d("DEBUG", uri.path.toString())
            uriList.add(uri)
        }
        TimeLapseEncoder(60, 20000).encode(cacheDir.path + "/video.mp4", uriList, contentResolver);
    }
}
