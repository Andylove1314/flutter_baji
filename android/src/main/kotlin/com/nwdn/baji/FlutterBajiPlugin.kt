package com.nwdn.baji

import android.content.Context
import android.graphics.BitmapFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterBajiPlugin */
class FlutterBajiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context  // 添加 context 变量

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext  // 保存 context
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_baji")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "saveImageWithDpi") {
            val imagePath = call.argument<String>("imagePath")
            val dpi = call.argument<Int>("dpi") ?: 300
            val name = call.argument<String>("name")
            val isJpg = call.argument<Boolean>("isJpg") ?: true

            if (imagePath == null || name == null) {
                result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                return
            }

            try {
                val bitmap = BitmapFactory.decodeFile(imagePath)
                val savedFile = ImageDpiUtil.saveBitmapToJpgWithDpi(
                    context,
                    bitmap,
                    dpi,
                    name,
                    isJpg
                )
                result.success(savedFile?.absolutePath)
            } catch (e: Exception) {
                result.error("SAVE_ERROR", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
