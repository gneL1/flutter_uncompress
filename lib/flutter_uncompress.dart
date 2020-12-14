
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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

  //通过字节流复制文件
  static Future copyFileByBytes({@required Uint8List bytes,@required String path,ValueChanged<int> callback}) async {

    int distance = bytes.length ~/ 100;
    int _start = 0;

    //目标文件
    File target = File(path);

    //以WRITE方式打开文件，创建缓存IOSink
    IOSink sink = target.openWrite();
    //文件大小
    int fileLength = bytes.lengthInBytes;
    //已读取文件大小
    int count = 0;

    for(int i = 0; i < 100; i++){
      _start = 0 + i * distance;
      List<int> value;
      if(i != 99)
        value = bytes.sublist(_start,_start + distance);
      else
        value = bytes.sublist(_start,bytes.length);

      count = count + value.length;
      double num = (count * 100) / fileLength;
      if(callback != null)callback(num.toInt());

      sink.add(value);
    }

    await sink.close();
  }

  static void init(){
    _channel.setMethodCallHandler((call){
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
