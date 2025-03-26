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


class MainActivity: FlutterActivity() {
    private val channel = "com.example.chronolapse/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "testFunction") {
                val count = call.argument<Int>("count")!!
                result.success(count + 1)
            } else if (call.method == "testMediaCodec") {
                testMediaCodec();
                result.success(true);
            } else {
                result.notImplemented()
            }
        }
    }

    private fun testMediaCodec() {
        Log.println(Log.DEBUG, "", "test")
        val width = 320
        val height = 240

        val mediaFormat = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, 4000)
            setInteger(MediaFormat.KEY_FRAME_RATE, 15)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 10)
        }



        Log.println(Log.DEBUG, "", "codec")
        val videoEncoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC).apply {
            configure(mediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        }

        val videoCapabilities = videoEncoder.codecInfo.getCapabilitiesForType("video/avc").videoCapabilities
        if (!videoCapabilities.supportedWidths.contains(width) || !videoCapabilities.supportedHeights.contains(height)) {
            Log.d("chtonolapse", "Encoder can't deal with $height x $width")

        }
        videoEncoder.start()


        /*val mediaMuxer = MediaMuxer(outputFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4).apply {
            val videoTrackIndex = addTrack(mediaFormat)
            start()
        }

        val bufferInfo = MediaCodec.BufferInfo()
        val outputBuffer = ByteBuffer.allocate(1024 * 1024)  // Buffer to hold encoded data*/
    }
}
