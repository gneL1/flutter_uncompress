
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterUncompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_uncompress');

  static ValueChanged<int> _callback;

  static bool _isFinish = true;

  static Future uncompress({@required String filePath,@required String uncompressPath}) async {
    if(!_isFinish)return;
    _isFinish = false;
    try{
      await _channel.invokeMethod('uncompressZipFile',{'filePath':filePath,'uncompressPath':uncompressPath});
      _isFinish = true;
    }
    catch(e){
      _isFinish = true;
    }
  }

  static void init(){
    _channel.setMethodCallHandler((call){
      print("当前值是${call.arguments}");
      if(_callback != null)
        _callback(call.arguments);
      return;
    });
  }



  ///获取解压进度
  static void onGetProgress({@required ValueChanged<int> callback}){
    _callback = callback;
  }
}
