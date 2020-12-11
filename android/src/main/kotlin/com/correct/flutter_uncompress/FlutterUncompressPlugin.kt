package com.correct.flutter_uncompress

import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** FlutterUncompressPlugin */
class FlutterUncompressPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_uncompress")
    channel.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "uncompressZipFile") {
      val filePath = call.argument("filePath") as String?
      val uncompressPath = call.argument("uncompressPath") as String?



//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
      GlobalScope.launch {
        val size = withContext(Dispatchers.Default) {
          MyZip.getSize(filePath)
        }
        Log.d("测试总数", size.toString())
        MyZip.unzip(filePath, uncompressPath, Callback {
          val pro: Double = String.format("%.2f", (it * 1.0 / size)).toDouble()

//                    tv1.text = "${pro * 100}%"
          val text = (pro * 100).toInt()
          Log.d("测试222", "当前进度是${pro}；当前text是${text}");
//          progressVM.progress.postValue(text)
//                    tv1.text = text.toString()
        })
      }

    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
