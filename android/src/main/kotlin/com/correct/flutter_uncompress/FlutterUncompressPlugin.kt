package com.correct.flutter_uncompress

import android.app.Activity
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.lang.ref.WeakReference


/** FlutterUncompressPlugin */
class FlutterUncompressPlugin: FlutterPlugin, MethodCallHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mActivity: WeakReference<Activity>


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_uncompress")
    channel.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    when(call.method){
      "uncompressZipFile" -> {
        val filePath = call.argument("filePath") as String?
        val uncompressPath = call.argument("uncompressPath") as String?

//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
        GlobalScope.launch {
          val size = withContext(Dispatchers.Default) {
            MyZip.getSize(filePath)
          }
          MyZip.unzip(filePath, uncompressPath, Callback {
            val pro: Double = String.format("%.2f", (it * 1.0 / size)).toDouble()
            val progress = (pro * 100).toInt()
            //Android 端发送数据要在主现场中调用
            mActivity.get()?.runOnUiThread {
              channel.invokeMethod("progress",progress)
            }
//          Log.d("测试222", "当前进度是${pro}；当前text是${text}");
//          progressVM.progress.postValue(text)
//                    tv1.text = text.toString()
          })
        }
        result.success(true)
      }
      
//      "copyFile" -> {
//        val bytes = call.argument("bytes") as ByteArray?
//        val copyPath = call.argument("copyPath") as String?
//
//        GlobalScope.launch {
//          withContext(Dispatchers.Default) {
//            MyZip.copyFile(bytes, copyPath,mActivity.get())
//          }
//        }
//        result.success(true)
//      }
      else -> result.notImplemented()
    }
    
  }
  

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    mActivity = WeakReference(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {
    mActivity.clear()
  }
}
